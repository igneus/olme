class MAIN

insert
   ARGUMENTS
   READ_LINE

create {ANY}
   make

feature {ANY}
   make
      local
         output: OUTPUT_STREAM
         fw: TEXT_FILE_WRITE
      do
         prompt := "> "
         read_line

         output := io
         if file_name /= Void then
            create fw.connect_to (file_name)
            output := fw
         end

         output.put_string (last_line)
         output.put_new_line

         if file_name /= Void then
            fw.disconnect
         end
      end

feature {}
   file_name: STRING
      do
         Result := Void

         if argument_count >= 1 then
            Result := argument (1)
         end
      end

end
