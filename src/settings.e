class SETTINGS
-- reads settings from command line arguments and environment
-- variables, exposes the values

insert
   COMMAND_LINE
      redefine
         fallback_editor,
         history_limit
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
         -- (string, because it's only used when constructing shell commands)
      once
         Result := history_limit.to_string
      end

   default_history_limit: INTEGER is 30

   history_limit: INTEGER
         -- How many recent commit messages to load from VCS history
      once
         if Precursor <= 0 then
            Result := default_history_limit
         else
            Result := Precursor
         end
      ensure
         Result > 0
      end

   file: REGULAR_FILE
         -- Input file
      once
         if file_name /= Void then
            create Result.make (file_name)

            if not (Result.exists and then Result.is_regular) then
               Result := Void
            end
         end
      ensure
         Result = Void or else (Result.exists and then Result.is_regular)
      end

feature {}
   system: SYSTEM

end
