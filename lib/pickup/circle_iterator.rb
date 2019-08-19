class Pickup
  class CircleIterator
    attr_reader :func, :obj, :max

    def initialize(obj, func, max, opts = {})
      @obj = obj.dup
      @func = func
      @max = max
      @key_func = Pickup.func_opt(opts[:key_func]) || key_func
      @weight_func = Pickup.func_opt(opts[:weight_func]) || weight_func
    end

    def key_func
      @key_func ||= proc { |item| item[0] }
    end

    def weight_func
      @weight_func ||= proc { |item| item[1] }
    end

    def each
      until obj.empty?
        start = 0

        obj.each do |item|
          key = key_func.call(item)
          weight = weight_func.call(item)

          val = func.call(weight)
          start += val

          if yield([key, start, max])
            obj.delete(key)
            @max -= val
          end
        end
      end
    end
  end
end
