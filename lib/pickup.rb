require "pickup/version"

class Pickup
  attr_reader :list, :uniq
  attr_writer :pick_func

  def initialize(list, uniq=false, &block)
    @list = list
    @uniq = uniq
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

  class MappedList
    include Enumerable
    attr_reader :list, :func, :uniq, :max

    def initialize(list, func, uniq=false)
      @func = func
      @uniq = uniq
      @list = list
      @current_state = 0
    end

    def each(&blk)
      item_iterator = next_item
      item = nil
      drop = false
      while true do
        item ||= item_iterator.call(drop)
        drop = false
        if uniq
          drop = true if yield item
          item = nil 
        else
          item = nil unless yield item
        end
      end
    end

    def next_item
      dup   = list.dup
      start = 0
      enum  = dup.to_enum
      item  = nil
      Proc.new do |drop|
        dup.delete item if drop
        item = begin
          enum.next
        rescue StopIteration => e
          enum = dup.to_enum
          enum.next
        end
        start += item[1]
        item[1] = start
        item
      end
    end

    def random(count)
      raise "List is shorter then count of items you want to get" if uniq && list.size < count
      nums = count.times.map{ func.call(rand(max)) }.sort
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
  end
end
