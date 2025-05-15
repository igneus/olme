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

   read_user_input
      local
         handling_sigint: BOOLEAN
         status: INTEGER
      do
         if handling_sigint = True then
            status := run_fallback
            die_with_code (status)
         end

         prompt := "olme editor: [Enter] to save and exit, [Ctrl+C] to run your default editor instead.%N> "
         read_line
      rescue
         if is_signal and then signal_number = 2 then
            -- TODO is it possible to somehow retrieve the text entered so far?
            handling_sigint := True
            retry
         end
      end

   file_name: STRING
      do
         Result := Void

         if argument_count >= 1 then
            Result := argument (1)
         end
      end

   fallback_editor: STRING
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
