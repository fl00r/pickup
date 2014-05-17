# encoding: utf-8
require 'spec_helper'
require 'ostruct'

describe Pickup do
  before do
    @list = {
      "selmon"  => 1,     # 1
      "carp" => 4,        # 5
      "crucian"  => 3,    # 8
      "herring" => 6,     # 14
      "sturgeon" => 8,    # 22
      "gudgeon" => 10,    # 32
      "minnow" => 20      # 52
    }

    @struct_list = @list.map{ |key, weight| OpenStruct.new(:key => key, :weight => weight) }

    @func = Proc.new{ |a| a }
    @pickup = Pickup.new(@list)
    @pickup2 = Pickup.new(@list, uniq: true)

    @key_func = Proc.new{ |item| item.key }
    @weight_func = Proc.new{ |item| item.weight }
    @pickup3 = Pickup.new(@struct_list, {:uniq => false}, @key_func, @weight_func)
  end

  it "should pick correct ammount of items" do
    @pickup.pick(2).size.must_equal 2
    @pickup.pick(10).size.must_equal 10
  end

  describe Pickup::MappedList do
    before do
      @ml = Pickup::MappedList.new(@list, @func, true)
      @ml2 = Pickup::MappedList.new(@list, @func)
      @ml3 = Pickup::MappedList.new(@struct_list, @func, false, @key_func, @weight_func)
      @ml4 = Pickup::MappedList.new(@struct_list, @func, true, @key_func, @weight_func)
    end

    it "should return selmon and then carp and then crucian for uniq pickup" do
      @ml.get_random_items([0, 0, 0]).must_equal ["selmon", "carp", "crucian"]
    end

    it "should return selmon 3 times for non-uniq pickup" do
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
    end

    it "should return crucian 3 times for uniq pickup" do
      @ml2.get_random_items([7, 7, 7]).must_equal ["crucian", "crucian", "crucian"]
    end

    it "should return item from the beginning after end of list for uniq pickup" do
      @ml.get_random_items([20, 20, 20, 20]).must_equal ["sturgeon", "gudgeon", "minnow", "crucian"]
    end

    it "should return right max" do
      @ml.max.must_equal 52
    end

    it "should return selmon 4 times for non-uniq pickup (using custom weight function)" do
      4.times{ @ml3.get_random_items([0]).first.must_equal "selmon" }
    end

    it "should return right max (using custom weight function)" do
      @ml3.max.must_equal 52
    end

    it "should return selmon and then carp and then crucian for uniq pickup (using custom weight function)" do
      @ml4.get_random_items([0, 0, 0]).must_equal ["selmon", "carp", "crucian"]
    end
  end

  it "should take 7 different fish" do
    items = @pickup2.pick(7)
    items.uniq.size.must_equal 7
  end

  it "should raise an exception" do
    proc{ items = @pickup2.pick(8) }.must_raise RuntimeError
  end

  it "should return include most weigtfull item (but not always - sometimes it will fail)" do
    items = @pickup2.pick(2){ |v| v**20 }
    (items.include? "minnow").must_equal true
  end

  it "should return include less weigtfull item (but not always - sometimes it will fail)" do
    items = @pickup2.pick(2){ |v| v**(-20) }
    (items.include? "selmon").must_equal true
  end

  it "should pick correct amount of items (using custom weight function)" do
    @pickup3.pick(4).size.must_equal 4
    @pickup3.pick(12).size.must_equal 12
  end

  it "should take 5 fish (using custom weight function)" do
    @pickup3.pick(5, @key_func, @weight_func).size.must_equal 5
  end
end