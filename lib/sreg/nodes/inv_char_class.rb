#
# Inversed character class, Sreg project
#
# An inversed character class is those like '[^abc]', \W and so on.
#
# Shou, 6th August, 2012
#


class Sreg
  module Builder
    module AbstractSyntaxTree

      module InversedCharacterClass

        def self.included(clazz)
          clazz.class_eval do
            alias_method :original_match_char?, :match_char?
            def match_char?(*args)
              return !original_match_char?(*args)
            end

            alias_method :original_as_json, :as_json
            def as_json
              original_as_json.merge(:inversed => true)
            end

            alias_method :original_class_name, :class_name
            def class_name
              "inversed-#{original_class_name}"
            end

          end
        end


      end

    end
  end
end

