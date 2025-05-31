class C_FUNCTIONS

feature {ANY}
   my_readline_init (first_line: POINTER)
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "my_readline_init"
         }"
      end

   is_fallback_requested: BOOLEAN
      do
         -- (The argument has no meaning, it's required because
         -- of a bug in Liberty Eiffel, see the corresponding C code)
         Result := is_fallback_requested_internal (1)
      end

feature {}
   is_fallback_requested_internal (i: INTEGER): BOOLEAN
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "is_fallback_requested"
         }"
      end

end
