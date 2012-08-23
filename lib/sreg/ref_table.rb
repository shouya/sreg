#
# Reference table for capturing
# Sreg project
#
# (c) Shou, August 18, 2012
#

class Sreg
  class ReferenceTable
    attr_accessor :number_map
    attr_accessor :name_map


    def initialize
      @number_map = []
      @name_map = {}
    end

    # Setting up
    def reset_number_map
      @number_map -= 1
    end

    def insert_number_map(grp_obj)
      @number_map << grp_obj
      return @number_map.length - 1
    end
    def set_number_map(n, grp_obj)
      @number_map[n] = grp_obj
      return n
    end
    def insert_name_group(name, grp_obj)
      # Multiple named capture is supported by this.
      name_map[name] ||= []
      name_map[name] << grp_obj
    end

    def is_number_type?
      @name_map.empty?
    end
    def is_name_type?
      !is_number_type?
    end
    def type
      @name_map.empty? ? :name : :number
    end

    def refer_by_name(name)
      @name_map[name]
    end
    def refer_by_number(no)
      @number_map[no]
    end
    def refer(handle)
      if handle.is_a? Integer
        refer_by_number(handle)
      elsif handle.is_a? Symbol or handle.is_a? String
        refer_by_name(handle.intern)
      else
        # error
        nil
      end

    end

  end
end
