deferred class MY_READ_LINE
-- READ_LINE with additional functionality.
--
-- Also this one is deferred, because READ_LINE is designed so that
-- some of the functionality (e.g. setting the prompt)
-- is accessible only to subclasses, not to clients.

inherit
   READ_LINE
      redefine
         read_line
      end

feature {ANY}
   -- If set, the readline entry field will be pre-populated with the
   -- given string.
   initial_content: ABSTRACT_STRING

   read_line
      local
         first_line_ptr: POINTER
      do
         if initial_content /= Void then
            first_line_ptr := initial_content.intern.to_external
         end
         my_readline_init (first_line_ptr)

         Precursor
      end

   is_fallback_requested: BOOLEAN
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "is_fallback_requested()"
         }"
         -- The parentheses in feature_name are a workaround:
         -- for calls of functions which don't receive arguments
         -- Liberty generates invalid C code, adding the parentheses
         -- here is a dirty fix
         -- https://savannah.gnu.org/bugs/index.php?67160
      end

feature {}
   my_readline_init (first_line: POINTER)
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "my_readline_init"
         }"
      end

end
