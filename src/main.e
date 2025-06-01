class MAIN

insert
   MY_READ_LINE
   PLURALIZER

create {ANY}
   make

feature {ANY}
   make
         -- Main entry point of the application
      do
         create settings.make

         if settings.is_valid then
            if settings.help_requested then
               settings.print_help (io)
            elseif settings.auto_fallback_requested and file_gist.lines_nonempty > 1 then
               run_fallback_and_exit
            else
               run
            end
         else
            settings.print_help (io)
            die_with_code (exit_failure_code)
         end
      end

feature {}
   settings: SETTINGS
   pf: PROCESS_FACTORY

   run
         -- Run the logic of file editing
      require
         settings.is_valid
      do
         if not settings.is_silent then
            print_tagline
            print_file_contents_warning
         end

         load_history
         read_user_input
         write_file

         if is_fallback_requested then
            run_fallback_and_exit
         end
      end

   file_gist: FILE_GIST
         -- Summary of the edited file's contents
      once
         Result := create {FILE_GIST}.make

         if settings.file /= Void then
            Result.load (settings.file.path)
         end
      end

   first_line: FIXED_STRING
         -- First line of the edited file - if available
      once
         if file_gist.first_line /= Void then
            create Result.make_from_string (file_gist.first_line)
         end
      end

   print_tagline
      do
         io.put_string ("olme editor: [Enter] to save and exit, [Ctrl+B] to run the fallback editor instead.%N")
      end

   print_file_contents_warning
         -- Print a warning if the file is non-empty
      do
         if file_gist.lines_total > 0 then
            io.put_string ("WARNING: the file has ")
            io.put_integer (file_gist.lines_total)
            io.put_string (" ")
            io.put_string (pluralize_simple ("line", file_gist.lines_total))

            if file_gist.lines_nonempty > 0 then
               io.put_string (", ")
               io.put_integer (file_gist.lines_nonempty)
               io.put_string (" of which ")
               io.put_string (pluralize_fork ("is", "are", file_gist.lines_nonempty))
               io.put_string (" non-empty")
            end

            io.put_new_line
         end
      end

   load_history
         -- Populate Readline history - if any source is specified
      do
         if settings.git_history_requested then
            -- command valid as of git v2.47
            load_history_cmd ("git", << "log", "--reverse", "--max-count", settings.history_entries, "--pretty=%%s" >>)
         end
         if settings.hg_history_requested then
            -- command valid as of Mercurial v6.9
            load_history_cmd ("hg", << "log", "--limit", settings.history_entries, "--template", "{desc|firstline}\n" >>)
         end
         if settings.custom_history_command /= Void then
            load_history_cmd (settings.shell, << "-c", settings.custom_history_command >>)
         end
      end

   load_history_cmd (command: STRING; args: TRAVERSABLE[STRING])
         -- Execute the specified command,
         -- add lines of its standard output to readline history.
      local
         p: PROCESS
      do
         p := pf.execute (command, args)

         from
            p.output.read_line
         until
            p.output.end_of_input
         loop
            history.add (create {STRING}.copy (p.output.last_string))

            p.output.read_line
         end

         p.wait
      end

   read_user_input
         -- Read one line of user input.
      do
         initial_content := first_line
         prompt := "> "
         read_line
      end

   run_fallback_and_exit
         -- Run the fallback editor and exit
      local
         p: PROCESS
         args: TRAVERSABLE[STRING]
         status: INTEGER
      do
         args := Void
         if settings.file_name /= Void then
            args := {FAST_ARRAY[STRING] << settings.file_name >> }
         end

         if settings.fallback_editor = Void then
            std_error.put_string ("ERROR: fallback editor not set up. Please provide the --fallback option or set the VISUAL or EDITOR environment variable.")
            std_error.put_new_line

            status := exit_failure_code
         else
            -- TODO is there a way to do the good old Unix exec(),
            --   replacing the current process with the new one?
            pf.set_keep_environment (True)
            pf.set_direct_input (True)
            pf.set_direct_output (True)
            pf.set_direct_error (True)

            p := pf.execute (settings.fallback_editor, args)

            p.wait
            status := p.status
         end

         die_with_code (status)
      end

   write_file
         -- Write editor contents to the specified file
      local
         output: OUTPUT_STREAM
         fr: TEXT_FILE_READ
         fw: TEXT_FILE_WRITE
      do
         output := io -- use stdout as default destination
         if settings.file_name /= Void then
            if settings.file /= Void then
               create fr.connect_to (settings.file_name)
               fr.read_line -- drop the first line
            end

            create fw.connect_to (settings.file_name) -- truncate and write
            output := fw
         end

         if last_line /= Void then
            output.put_string (last_line)
            output.put_new_line
         end

         if fr /= Void then
            from
               fr.read_line
            until
               fr.end_of_input
            loop
               output.put_string (fr.last_string)
               output.put_new_line

               fr.read_line
            end

            fr.disconnect
         end

         if settings.file_name /= Void then
            fw.disconnect
         end
      end

end
