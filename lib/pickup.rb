require 'pickup/version'

class Pickup
  require 'pickup/circle_iterator'
  require 'pickup/mapped_list'

  attr_reader :list, :uniq
  attr_writer :pick_func, :key_func, :weight_func

  def initialize(list, opts = {}, &block)
    @list = list
    @uniq = opts[:uniq] || false
    @pick_func = block if block_given?
    @key_func = Pickup.func_opt(opts[:key_func])
    @weight_func = Pickup.func_opt(opts[:weight_func])
  end

  def pick(count = 1, opts = {}, &block)
    func = block || pick_func
    key_func = Pickup.func_opt(opts[:key_func]) || @key_func
    weight_func = Pickup.func_opt(opts[:weight_func]) || @weight_func
    mlist = MappedList.new(list, func, uniq: uniq, key_func: key_func, weight_func: weight_func)
    result = mlist.random(count)
    count == 1 ? result.first : result
  end

  def pick_func
    @pick_func ||= proc { |val| val }
  end

  def self.func_opt(opt)
    opt.is_a?(Symbol) ? opt.to_proc : opt
  end
end
