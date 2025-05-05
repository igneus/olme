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
            create fw.connect_to (file_name)
            output := fw
         end

         output.put_string (last_line)
         output.put_new_line

         if file_name /= Void then
            fw.disconnect
         end
      end

feature {}
   read_user_input
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
      once
         -- TODO
         Result := "vim"
      end

   run_fallback: INTEGER
      local
         pf: PROCESS_FACTORY
         p: PROCESS
         args: TRAVERSABLE[STRING]
      do
         if file_name /= Void then
            args := {FAST_ARRAY[STRING] << file_name >> }
         end

         -- TODO is there a way to do the good old Unix exec(),
         --   replacing the current process with the new one?
         pf.set_keep_environment (True)
         pf.set_direct_input (True)
         pf.set_direct_output (True)
         pf.set_direct_error (True)

         -- TODO editor hardcoded
         p := pf.execute ("vim", args)

         p.wait
         Result := p.status
      end

end
