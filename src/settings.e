class SETTINGS
-- reads settings from command line arguments and environment
-- variables, exposes the values

create
   make

feature {}
   command_line: COMMAND_LINE

feature {ANY}
   make
      do
         create command_line.make
      end

   print_help (output: OUTPUT_STREAM)
      do
         command_line.print_help (output)
      end

   is_valid: BOOLEAN
      once
         Result := command_line.is_valid
      end

   help_requested: BOOLEAN
      once
         Result := command_line.help_requested
      end

   file_name: STRING
      once
         Result := command_line.file_name
      end

   fallback_editor: STRING
         -- Determines the fallback editor.
      local
         cmd: STRING
         i: INTEGER
         vars: ARRAY[STRING]
         system: SYSTEM
      once
         if command_line.fallback_editor /= Void then
            Result := command_line.fallback_editor
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
