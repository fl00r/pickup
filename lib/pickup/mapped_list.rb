class Pickup
  class MappedList
    attr_reader :list, :func, :uniq

    BOOLEAN_DEPRECATION ||= '[DEPRECATED] Passing uniq as a boolean to ' \
    "MappedList's initialize method is deprecated. Please use the opts hash " \
    'instead.'.freeze

    def initialize(list, func, opts = nil)
      if opts.is_a?(Hash)
        @key_func = Pickup.func_opt(opts[:key_func]) || key_func
        @weight_func = Pickup.func_opt(opts[:weight_func]) || weight_func
        @uniq = opts[:uniq] || false
      else
        # If opts is explicitly provided as a boolean, show the warning.
        warn BOOLEAN_DEPRECATION if [true, false].include?(opts)

        @uniq = opts || false
      end

      @func = func
      @list = list
      @current_state = 0
    end

    def key_func
      @key_func ||= proc { |item| item[0] }
    end

    def weight_func
      @weight_func ||= proc { |item| item[1] }
    end

    def max
      @max ||= list.sum { |item| func.call(weight_func.call(item)) }
    end

    def each(*)
      CircleIterator.new(
        @list, func, max, key_func: key_func, weight_func: weight_func
      ).each do |item|
        if uniq
          true if yield item
        else
          nil while yield(item)
        end
      end
    end

    def random(count)
      if uniq && list.size < count
        raise 'List is shorter than count of items you want to get'
      end

      nums = count.times.map { rand(max) }.sort
      return [] if max.zero?

      get_random_items(nums)
    end

    def get_random_items(nums)
      current_num = nums.shift
      items = []
      each do |item, counter, mx|
        break unless current_num
        next unless counter % (mx + 1) > current_num % mx

        items << item
        current_num = nums.shift
      end
      items
    end
  end
end
