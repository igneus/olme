class FILE_GIST
-- Everything olme needs to know about the file's contents

create {ANY}
   make,
   load

feature {ANY}
   lines_total: INTEGER

   lines_nonempty: INTEGER

   first_line: STRING

   make
         -- Initialize an empty instance
      do
         lines_total := 0
         lines_nonempty := 0
         first_line := Void
      end

   load (path: ABSTRACT_STRING)
         -- Load stats of the specified file
      local
         fr: TEXT_FILE_READ
      do
         make

         create fr.connect_to (path)

         from
            fr.read_line
            if fr.last_string /= Void then
               create first_line.copy (fr.last_string)
            end
         until
            fr.end_of_input
         loop
            lines_total := lines_total + 1

            -- lines of zero length
            -- and lines beginning with the '#' shell comment
            -- character are considered empty
            if (not fr.last_string.is_empty) and then fr.last_string.item (1) /= '#' then
               lines_nonempty := lines_nonempty + 1
            end

            fr.read_line
         end

         fr.disconnect
      end

end
