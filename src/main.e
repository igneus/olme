class MAIN

insert
   ARGUMENTS
   READ_LINE

create {ANY}
   make

feature {ANY}
   make
      local
         output: OUTPUT_STREAM
         fw: TEXT_FILE_WRITE
      do
         io.put_string ("olme editor: [Enter] to save and exit, [Ctrl+C] to run your default editor instead.%N")
         print_file_contents_warning

         read_user_input

         output := io
         if file_name /= Void then
            create fw.connect_to (file_name) -- truncate and write
            output := fw
         end

         output.put_string (last_line)
         output.put_new_line

         if file_name /= Void then
            fw.disconnect
         end
      end

feature {}
   system: SYSTEM

   print_file_contents_warning
         -- Prints a warning if the file is non-empty
      local
         file: REGULAR_FILE
         fr: TEXT_FILE_READ
         lines_total, lines_nonempty: INTEGER
      do
         if file_name /= Void then
            create file.make (file_name)

            if file.exists and then file.is_regular then
               create fr.connect_to (file_name)

               lines_total := 0
               lines_nonempty := 0

               from
                  fr.read_line
               until
                  fr.end_of_input
               loop
                  lines_total := lines_total + 1

                  -- lines of zero length
                  -- and lines beginning with the '#' shell comment
                  -- character are considered empty
                  if (not fr.last_string.is_empty) and then fr.last_string.item (1) /= '#' then
                     lines_nonempty := lines_nonempty + 1
                  end

                  fr.read_line
               end

               fr.disconnect

               if lines_total > 0 then
                  io.put_string ("WARNING: the file has ")
                  io.put_integer (lines_total)
                  io.put_string (" lines")

                  if lines_nonempty > 0 then
                     io.put_string (", ")
                     io.put_integer (lines_nonempty)
                     io.put_string (" of which are non-empty")
                  end

                  io.put_new_line
               end
            end
         end
      end

   read_user_input
         -- Reads one line of user input.
         -- On SIGINT runs the fallback editor and exits.
      local
         handling_sigint: BOOLEAN
         status: INTEGER
      do
         if handling_sigint = True then
            status := run_fallback
            die_with_code (status)
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

   file_name: STRING
         -- Name of the file to be edited. May be Void.
      do
         Result := Void

         if argument_count >= 1 then
            Result := argument (1)
         end
      end

   fallback_editor: STRING
         -- Determines the fallback editor.
      local
         cmd: STRING
         i: INTEGER
         vars: ARRAY[STRING]
      once
         vars := << "VISUAL", "EDITOR" >>

         from
            i := vars.lower
         until
            i > vars.upper or cmd /= Void
         loop
            cmd := system.get_environment_variable (vars.item (i))

            if cmd /= Void and then cmd.is_empty then
               cmd := Void
            end

            i := i + 1
         end

         Result := cmd
      ensure
         Result = Void or else Result.count > 0
      end

   run_fallback: INTEGER
         -- Runs the fallback editor, returns its exit code.
      local
         pf: PROCESS_FACTORY
         p: PROCESS
         args: TRAVERSABLE[STRING]
      do
         args := Void
         if file_name /= Void then
            args := {FAST_ARRAY[STRING] << file_name >> }
         end

         if fallback_editor = Void then
            std_error.put_string ("ERROR: fallback editor not set up. Please set the VISUAL or EDITOR environment variable.")
            std_error.put_new_line

            Result := exit_failure_code
         else
            -- TODO is there a way to do the good old Unix exec(),
            --   replacing the current process with the new one?
            pf.set_keep_environment (True)
            pf.set_direct_input (True)
            pf.set_direct_output (True)
            pf.set_direct_error (True)

            p := pf.execute (fallback_editor, args)

            p.wait
            Result := p.status
         end
      end

end
