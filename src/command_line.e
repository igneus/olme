class COMMAND_LINE
-- Parses command line arguments, exposes values

create
   make

feature {}
   args: COMMAND_LINE_ARGUMENTS
   factory: COMMAND_LINE_ARGUMENT_FACTORY

feature {ANY}
   is_valid: BOOLEAN

   make
      do
         create factory
         create args.make (
            factory.no_parameters or
            (opt_help and opt_silent and opt_fallback and arg_file)
                          )

         is_valid := args.parse_command_line
      end

   print_help (output: OUTPUT_STREAM)
         -- Print help to the provided stream
      do
         args.usage (output)
      end

   help_requested: BOOLEAN
      require
         is_valid
      once
         Result := opt_help.is_set
      end

   is_silent: BOOLEAN
      require
         is_valid
      once
         Result := opt_silent.is_set
      end

   fallback_editor: STRING
      require
         is_valid
      once
         if opt_fallback.is_set then
            Result := opt_fallback.item.string
         end
      end

   file_name: STRING
      require
         is_valid
      once
         if arg_file.is_set then
            Result := arg_file.item.string
         end
      end

feature {}
   arg_file: COMMAND_LINE_TYPED_ARGUMENT[FIXED_STRING]
      once
         Result := factory.positional_string ("file", "file to edit - will be overwritten!")
      end

   opt_help: COMMAND_LINE_TYPED_ARGUMENT[BOOLEAN]
      once
         Result := factory.option_boolean ("h", "help", "Print this help and exit")
      end

   opt_silent: COMMAND_LINE_TYPED_ARGUMENT[BOOLEAN]
      once
         Result := factory.option_boolean ("s", "silent", "Reduce output to the bare minimum")
      end

   opt_fallback: COMMAND_LINE_TYPED_ARGUMENT[FIXED_STRING]
      once
         Result := factory.option_string ("f", "fallback", "EDITOR", "Editor to run as fallback for multi-line editing - the VISUAL and EDITOR environment variables are used by default")
      end

end
