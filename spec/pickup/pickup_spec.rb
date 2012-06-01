# encoding: utf-8
require 'spec_helper'

describe Pickup do
  before do
    @list = {
      "selmon"  => 1,
      "carp" => 4,
      "crucian"  => 3,
      "herring" => 6,
      "sturgeon" => 8,
      "gudgeon" => 10,
      "minnow" => 20
    }
    @func = Proc.new{ |a| a }
    @pickup = Pickup.new(@list)
    @pickup2 = Pickup.new(@list, uniq: true)
  end

  it "should pick correct ammount of items" do
    @pickup.pick(2).size.must_equal 2
    @pickup.pick(10).size.must_equal 10
  end

  describe Pickup::MappedList do
    before do
      @ml = Pickup::MappedList.new(@list, @func, true)
      @ml2 = Pickup::MappedList.new(@list, @func)
    end

    it "should return selmon and then carp and then crucian for uniq pickup" do
      @ml.get_random_items([0, 0, 0]).must_equal ["selmon", "carp", "crucian"]
    end

    it "should return selmon 3 times for non-uniq pickup" do
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
      @ml2.get_random_items([0]).first.must_equal "selmon"
    end

    it "should return item from the beginning after end of list for uniq pickup" do
      @ml.get_random_items([20, 20, 20, 20]).must_equal ["sturgeon", "gudgeon", "minnow", "selmon"]
    end
  end

  it "should take 7 different fish" do
    items = @pickup2.pick(7)
    items.uniq.size.must_equal 7
  end

  it "should raise an exception" do
    proc{ items = @pickup2.pick(8) }.must_raise RuntimeError
  end
end