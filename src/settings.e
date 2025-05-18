class SETTINGS
-- reads settings from command line arguments and environment
-- variables, exposes the values

insert
   COMMAND_LINE
      rename
         fallback_editor as cli_fallback_editor
      end

create {ANY}
   make

feature {ANY}
   fallback_editor: STRING
         -- Determines the fallback editor.
      local
         cmd: STRING
         i: INTEGER
         vars: ARRAY[STRING]
         system: SYSTEM
      once
         if cli_fallback_editor /= Void then
            Result := cli_fallback_editor
         else
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
         end
      ensure
         Result = Void or else Result.count > 0
      end

end
