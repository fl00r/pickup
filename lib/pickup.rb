require "pickup/version"

class Pickup
  attr_reader :list, :uniq
  attr_writer :pick_func

  def initialize(list, opts={}, &block)
    @list = list
    @uniq = opts[:uniq] || false
    @pick_func = block if block_given?
  end

  def pick(count=1, &block)
    func = block || pick_func
    mlist = MappedList.new(list, func, uniq)
    result = mlist.random(count)
    count == 1 ? result.first : result
  end

  def pick_func
    @pick_func ||= begin
      Proc.new do |val|
        val
      end
    end
  end

  class CircleIterator
      def initialize(obj)
        @obj = obj.dup
      end

      def each
        start = 0
        until @obj.empty?
          @obj.each do |item, weight|
            start += weight
            if yield([item, start])
              @obj.delete item
            end
          end
        end
      end
    end

  class MappedList
    attr_reader :list, :func, :uniq

    def initialize(list, func, uniq=false)
      @func = func
      @uniq = uniq
      @list = list
      @current_state = 0
    end

    def each(&blk)
      CircleIterator.new(@list).each do |item|
        if uniq
          true if yield item
        else
          nil while yield(item)
        end
      end
    end

    def random(count)
      raise "List is shorter then count of items you want to get" if uniq && list.size < count
      nums = count.times.map{ rand(func.call(max)) }.sort
      get_random_items(nums)
    end

    def get_random_items(nums)
      next_num = Proc.new{ nums.shift }
      current_num = next_num.call
      items = []
      each do |item, counter|
        break unless current_num
        val = func.call(counter)
        if val > current_num
          items << item
          current_num = next_num.call
          true
        end
      end
      items
    end

    def max
      @max ||= begin
        list.inject(0){ |mx, item| mx += item[1]}
      end
    end
  end
end
