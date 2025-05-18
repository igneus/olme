class FILE_STATS

create {ANY}
   make

feature {ANY}
   lines_total: INTEGER

   lines_nonempty: INTEGER

   make
      do
         lines_total := 0
         lines_nonempty := 0
      end

   -- the `assign` keyword has in Liberty semantics completely opposite
   -- to ISE Eiffel, cf. https://www.eiffel.org/doc/eiffel/ET-_The_Dynamic_Structure-_Execution_Model#Assigner_commands
   set_lines_total (value: INTEGER) assign lines_total
      do
         lines_total := value
      end

   set_lines_nonempty (value: INTEGER) assign lines_nonempty
      do
         lines_nonempty := value
      end

end
