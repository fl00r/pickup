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
    attr_reader :func, :obj

    def initialize(obj, func)
      @obj = obj.dup
      @func = func
    end

    def each
      mx = max
      until obj.empty?
        start = 0
        obj.each do |item, weight|
          val = func.call(weight)
          start += val
          if yield([item, start, mx])
            obj.delete item
            mx = max
          end
        end
      end
    end

    def max
      max = 0
      obj.each{ |item| max += func.call(item[1]) }
      max
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
      CircleIterator.new(@list, func).each do |item|
        if uniq
          true if yield item
        else
          nil while yield(item)
        end
      end
    end

    def random(count)
      raise "List is shorter then count of items you want to get" if uniq && list.size < count
      nums = count.times.map{ rand(max) }.sort
      get_random_items(nums)
    end

    def get_random_items(nums)
      next_num = Proc.new{ nums.shift }
      current_num = next_num.call
      items = []
      each do |item, counter, mx|
        break unless current_num
        if counter%(mx+1) > current_num%mx
          items << item
          current_num = next_num.call
          true
        end
      end
      items
    end

    def max
      max = 0
      list.each{ |item| max += func.call(item[1]) }
      max
    end
  end
end
