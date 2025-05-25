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

   is_fallback_requested (i: INTEGER): BOOLEAN
      external "plug_in"
      alias "{
         location: "."
         module_name: "plugin"
         feature_name: "is_fallback_requested"
         }"
      end

end
