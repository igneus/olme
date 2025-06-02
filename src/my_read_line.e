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
   initial_content: FIXED_STRING

   read_line
      local
         first_line_ptr: POINTER
      do
         if initial_content /= Void then
            first_line_ptr := initial_content.to_external
         end
         my_readline_init (first_line_ptr)

         Precursor
      end

   is_fallback_requested: BOOLEAN
      do
         Result := is_fallback_requested_internal (1)
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

   is_fallback_requested_internal (i: INTEGER): BOOLEAN
         -- (The argument has no meaning, it's required because
         -- of a bug in Liberty Eiffel, see the corresponding C code)
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "is_fallback_requested"
         }"
      end

end
