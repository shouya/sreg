#
# Bunch, a bunch elements.
# Sreg project
#
# Shou, 1 August 2012
#

module Sreg
  module Builder
    module AbstractSyntaxTree
      class Bunch < Node
        attr_reader :elements

        def initialize(elements = [])
          @elements = elements
          @valid = nil

          @elements.each { |x| x.parent = self }
        end
        def append(element)
          @elements << element
          element.parent = self
          self
        end

        def optimize
          str_buf = []
          result_buf = []
          @elements.each do |x|
            if Character === x
              str_buf << x.character
            else
              if str_buf.empty?
                result_buf << x.optimize
              else
                result_buf << String.new(str_buf)
                str_buf = []
                result_buf << x.optimize
              end
            end
          end
          result_buf << String.new(str_buf) unless str_buf.empty?


          if result_buf.length == 1
            return result_buf[0]
          else
            return Bunch.new(result_buf)
          end

        end

        # Compile time
        def as_json
          elements.map(&:as_json)
        end
        def to_s
          elements.map(&:to_s).join
        end
        def match_result(string)
          @elements.map { |x| x.match_result(string) }
=begin
          pos = 0
          arr = []

          @elements.each do |x|
            if x.class.method_defined? :match
              arr << x.match(string[pos..-1])
            else
              arr << x.as_json.merge(:match => string[pos, x.length])
            end
            pos += x.length
          end
          arr
=end
        end

        # Run time

        def length
          @elements.map(&:length).inject(0, &:+)
        end

        def compromise?(to_which)
#          @elements.any(&:compromise?)
          @elements.reverse.any?(&:compromise?)
        end

#        attr :valid
        def valid?
          return @elements.all?(&:valid?)
        end

        def reset(string, *)
          super
          reset_from(string, 0)
        end


        def reset_from(string, start_from)
          interrupted = nil
          failed_item_index = nil

          pos = @elements[0...start_from].map(&:length).inject(0, &:+)
          pos += @position

          @elements[start_from..-1].each_with_index do |x, idx|
            if x.reset(string, pos)
              pos += x.length
            else
              interrupted = true
              failed_item_index = idx + start_from
              break
            end
          end

          # return length
          return (pos - @position) unless interrupted


          # interrupted
          if start = compromise_from(failed_item_index, string)
            return reset_from(string, start)
          else
            return false
          end
        end

        def compromise_from(failed_item_index, string)
          @elements[0...failed_item_index].reverse.each_with_index do |x, idx|
            if x.compromise?
              x.compromise(string)
              return failed_item_index - idx
            end
          end
          return false
        end


      end

    end
  end
end
