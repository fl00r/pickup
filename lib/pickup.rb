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
    result = count.times.map do |i|
      mlist.random
    end
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
    attr_reader :list, :func, :uniq, :max

    def initialize(list, func, uniq=false)
      @func = func
      @uniq = uniq
      @list = map_list(list)
    end

    def random
      num = rand(max)
      get_random_item(num)
    end

    def get_random_item(n)
      item = list.detect do |k,v|
        val = func.call v[:value]
        num = func.call n
        (val >= num) && !(uniq && v[:picked])
      end
      item ||= list.detect{ |k,v| !v[:picked] }
      raise "No items left" unless item
      key = item[0]
      list[key][:picked] = true if uniq
      key
    end
    
  private

    def map_list(list)
      @max = 0
      mapped_list = {}
      list.each do |k, v|
        mapped_list[k] = {}
        mapped_list[k][:value] = @max
        @max += v
        mapped_list[k][:picked] = false if uniq
      end
      mapped_list
    end
  end
end
