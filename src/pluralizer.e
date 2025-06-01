class PLURALIZER
-- Helper methods handling quantities in English UI messages

feature {ANY}
   pluralize_simple (singular: ABSTRACT_STRING, quantity: INTEGER): ABSTRACT_STRING
      do
         if quantity = 1 then
            Result := singular
         else
            Result := singular & "s"
         end
      end

   pluralize_fork (singular, plural: ABSTRACT_STRING, quantity: INTEGER): ABSTRACT_STRING
      do
         if quantity = 1 then
            Result := singular
         else
            Result := plural
         end
      end

end
