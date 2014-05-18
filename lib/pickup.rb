require "pickup/version"

class Pickup
  attr_reader :list, :uniq
  attr_writer :pick_func, :key_func, :weight_func

  def initialize(list, opts={}, &block)
    @list = list
    @uniq = opts[:uniq] || false
    @pick_func = block if block_given?
    @key_func = opts[:key_func]
    @weight_func = opts[:weight_func]
  end

  def pick(count=1, opts={}, &block)
    func = block || pick_func
    key_func = opts[:key_func] || @key_func
    weight_func = opts[:weight_func] || @weight_func
    mlist = MappedList.new(list, func, uniq, key_func: key_func, weight_func: weight_func)
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
    attr_reader :func, :obj, :max, :key_func, :weight_func

    def initialize(obj, func, max, opts={})
      @obj = obj.dup
      @func = func
      @max = max
      @key_func = opts[:key_func] || key_func
      @weight_func = opts[:weight_func] || weight_func
    end

    def key_func
      @key_func ||= begin
        Proc.new do |item|
          item[0]
        end
      end
    end

    def weight_func
      @weight_func ||= begin
        Proc.new do |item|
          item[1]
        end
      end
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
            obj.delete key
            @max -= val
          end
        end
      end
    end
  end

  class MappedList
    attr_reader :list, :func, :uniq, :key_func, :weight_func

    def initialize(list, func, uniq=false, opts={})
      @func = func
      @uniq = uniq
      @list = list
      @key_func = opts[:key_func]
      @weight_func = opts[:weight_func] || weight_func
      @current_state = 0
    end

    def weight_func
      @weight_func ||= begin
        Proc.new do |item|
          item[1]
        end
      end
    end

    def each(&blk)
      CircleIterator.new(@list, func, max, key_func: @key_func, weight_func: weight_func).each do |item|
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
      current_num = nums.shift
      items = []
      each do |item, counter, mx|
        break unless current_num
        if counter%(mx+1) > current_num%mx
          items << item
          current_num = nums.shift
          true
        end
      end
      items
    end

    def max
      @max ||= begin
        max = 0
        list.each{ |item| max += func.call(weight_func.call(item)) }
        max
      end
    end
  end
end
