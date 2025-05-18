class MAIN

insert
   READ_LINE

create {ANY}
   make

feature {ANY}
   make
      do
         create settings.make

         if settings.is_valid then
            if settings.help_requested then
               settings.print_help (io)
            elseif settings.auto_fallback_requested and file_stats.lines_nonempty > 1 then
               run_fallback
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
      local
         output: OUTPUT_STREAM
         fw: TEXT_FILE_WRITE
      do

         if not settings.is_silent then
            io.put_string ("olme editor: [Enter] to save and exit, [Ctrl+C] to run the fallback editor instead.%N")
            print_file_contents_warning
         end

         if settings.git_history_requested then
            -- command valid as of git v2.47
            load_history ("git", << "log", "--max-count", settings.history_entries, "--pretty=%%s" >>)
         end
         if settings.hg_history_requested then
            -- command valid as of Mercurial v6.9
            load_history ("hg", << "log", "--limit", settings.history_entries, "--template", "{desc|firstline}\n" >>)
         end
         if settings.custom_history_command /= Void then
            load_history (settings.shell, << "-c", settings.custom_history_command >>)
         end

         read_user_input

         output := io
         if settings.file_name /= Void then
            create fw.connect_to (settings.file_name) -- truncate and write
            output := fw
         end

         if last_line /= Void then
            output.put_string (last_line)
            output.put_new_line
         end

         if settings.file_name /= Void then
            fw.disconnect
         end
      end

   file_stats: FILE_STATS
      local
         file: REGULAR_FILE
      once
         Result := create {FILE_STATS}.make

         if settings.file_name /= Void then
            create file.make (settings.file_name)

            if file.exists and then file.is_regular then
               Result.load (settings.file_name)
            end
         end
      end

   print_file_contents_warning
         -- Print a warning if the file is non-empty
      do
         if file_stats.lines_total > 0 then
            io.put_string ("WARNING: the file has ")
            io.put_integer (file_stats.lines_total)
            io.put_string (" lines")

            if file_stats.lines_nonempty > 0 then
               io.put_string (", ")
               io.put_integer (file_stats.lines_nonempty)
               io.put_string (" of which are non-empty")
            end

            io.put_new_line
         end
      end

   load_history (command: STRING; args: TRAVERSABLE[STRING])
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
         -- On SIGINT run the fallback editor and exit.
      local
         handling_sigint: BOOLEAN
      do
         if handling_sigint = True then
            run_fallback -- does not return
         end

         prompt := "> "
         read_line
      rescue
         if is_signal and then signal_number = 2 then
            -- TODO is it possible to somehow retrieve the text entered so far?
            handling_sigint := True
            retry
         end
      end

   run_fallback
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
            std_error.put_string ("ERROR: fallback editor not set up. Please set the VISUAL or EDITOR environment variable.")
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

end
