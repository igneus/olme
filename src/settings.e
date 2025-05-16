class SETTINGS
-- reads settings from command line arguments and environment
-- variables, exposes the values

insert
   ARGUMENTS

feature {ANY}
   file_name: STRING
         -- Name of the file to be edited. May be Void.
      once
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
         system: SYSTEM
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

end
