class PLURALIZER
-- Helper methods handling quantities in English UI messages

feature {ANY}
   pluralize_simple (singular: ABSTRACT_STRING, quantity: INTEGER): ABSTRACT_STRING
      require
         quantity >= 1
         not singular.is_empty
      do
         if quantity = 1 then
            Result := singular
         else
            Result := singular & "s"
         end
      ensure
         Result.has_prefix (singular)
      end

   pluralize_fork (singular, plural: ABSTRACT_STRING, quantity: INTEGER): ABSTRACT_STRING
      require
         quantity >= 1
         not singular.is_empty
         not plural.is_empty
      do
         if quantity = 1 then
            Result := singular
         else
            Result := plural
         end
      ensure
         Result = singular or else Result = plural
      end

end
