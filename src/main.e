class MAIN

insert
   MY_READ_LINE

create {ANY}
   make

feature {ANY}
   make
         -- Main entry point of the application
      local
         signal_received: BOOLEAN
      do
         create msg

         if signal_received then
            msg.print_signal_received (signal_number)
            die_with_code (exit_failure_code)
         end

         process_settings
      rescue
         if is_signal then
            signal_received := True
            retry
         end
      end

feature {}
   settings: SETTINGS
   pf: PROCESS_FACTORY
   msg: MESSAGES

   process_settings
         -- Collect settings and do as they command
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

   run
         -- Run the logic of file editing
      require
         settings.is_valid
      do
         if not settings.is_silent then
            msg.print_tagline
            msg.print_file_contents_warning (file_gist)
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
         create Result.make

         if settings.file /= Void then
            Result.load (settings.file.path)
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

         if p.status /= exit_success_code then
            msg.external_command_error ("loading history", command, p.status)
         end
      end

   read_user_input
         -- Read one line of user input.
      do
         if file_gist.first_line /= Void then
            initial_content := create {FIXED_STRING}.make_from_string (file_gist.first_line)
         end

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
            msg.print_fallback_editor_not_set
            status := exit_failure_code
         else
            -- TODO is there a way to do the good old Unix exec(),
            --   replacing the current process with the new one?
            pf.set_keep_environment (True)
            pf.set_direct_input (True)
            pf.set_direct_output (True)

            -- TODO: we want `set_direct_error (True)`, too, but
            --   currently it's broken: https://savannah.gnu.org/bugs/?67196
            -- pf.set_direct_error (True)

            p := pf.execute (settings.fallback_editor, args)

            p.wait
            status := p.status

            if p.status /= exit_success_code then
               msg.external_command_error ("fallback editor", settings.fallback_editor, p.status)
            end
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

         if fw /= Void then
            fw.disconnect
         end
      end

end
