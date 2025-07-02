class MESSAGES
-- Builds and prints all olme's UI messages

insert
   PLURALIZER

feature {ANY}
   print_signal_received (signal_number: INTEGER)
      do
         std_error.put_string ("Received signal ")
         std_error.put_integer (signal_number)
         std_error.put_new_line
      end

   print_tagline
      do
         io.put_string ("olme editor: [Enter] to save and exit, [Ctrl+B] to run the fallback editor instead.%N")
      end

   print_file_contents_warning (file_gist: FILE_GIST)
         -- Print a warning if the file is non-empty
      do
         if file_gist.lines_total > 0 then
            io.put_string ("WARNING: the file has ")
            io.put_integer (file_gist.lines_total)
            io.put_string (" ")
            io.put_string (pluralize_simple ("line", file_gist.lines_total))

            io.put_string (" (")
            if file_gist.lines_nonempty > 0 then
               if file_gist.lines_nonempty = file_gist.lines_total then
                  io.put_string ("all")
               else
                  io.put_integer (file_gist.lines_nonempty)
               end
               io.put_string (" non-empty")
            else
               io.put_string ("all empty")
            end
            io.put_string (")")

            io.put_new_line
         end
      end

   print_fallback_editor_not_set
      do
         std_error.put_string ("ERROR: fallback editor not set up. Please provide the --fallback option or set the VISUAL or EDITOR environment variable.%N")
      end

   external_command_error (label, command: STRING; exit_code: INTEGER)
      do
         std_error.put_string ("ERROR " + label + ": ")
         std_error.put_string ("'" + command + "' returned status ")
         std_error.put_integer (exit_code)
         std_error.put_new_line
      end

end
