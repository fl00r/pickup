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
  end

  it "should pick correct ammount of items" do
    @pickup.pick(2).size.must_equal 2
  end

  describe Pickup::MappedList do
    before do
      @mapped_list = {"selmon"=>{:value=>1, :picked=>false}, "carp"=>{:value=>5, :picked=>false}, "crucian"=>{:value=>8, :picked=>false}, "herring"=>{:value=>14, :picked=>false}, "sturgeon"=>{:value=>22, :picked=>false}, "gudgeon"=>{:value=>32, :picked=>false}, "minnow"=>{:value=>52, :picked=>false}}
      @ml = Pickup::MappedList.new(@list, @func, true)
      @ml2 = Pickup::MappedList.new(@list, @func)
    end

    it "should return right mapped list" do
      @ml.list.must_equal(@mapped_list)
    end

    it "should return selmon and then carp and then crucian for uniq pickup" do
      @ml.get_random_item(1).must_equal "selmon"
      @ml.get_random_item(1).must_equal "carp"
      @ml.get_random_item(1).must_equal "crucian"
    end

    it "should return selmon 3 times for non-uniq pickup" do
      @ml2.get_random_item(1).must_equal "selmon"
      @ml2.get_random_item(1).must_equal "selmon"
      @ml2.get_random_item(1).must_equal "selmon"
    end

    it "should return item from the beginning after end of list for uniq pickup" do
      @ml.get_random_item(30).must_equal "gudgeon"
      @ml.get_random_item(30).must_equal "minnow"
      @ml.get_random_item(30).must_equal "selmon"
    end
  end
end