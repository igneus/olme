class SETTINGS
-- reads settings from command line arguments and environment
-- variables, exposes the values

insert
   COMMAND_LINE
      redefine
         fallback_editor
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
      once
         if Precursor /= Void then
            Result := Precursor
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

   shell: STRING
         -- The user's preferred shell.
      once
         Result := system.get_environment_variable ("SHELL")

         if Result = Void or else Result.is_empty then
            Result := "/bin/sh"
         end
      end

   history_entries: STRING
         -- How many recent commit messages to load from VCS history
         -- (string, because its only used when constructing shell commands)
      once
         Result := "30"
      end

feature {}
   system: SYSTEM

end
