require 'benchmark'
require './lib/pickup'

def simple_hash
  @simple ||= begin
    hash = {}
    (1..30).to_a.each do |i|
      hash["item_#{i}"] = rand(30)
    end
    hash
  end
end

def big_hash
  @big ||= begin
    hash = {}
    (1..5000).to_a.each do |i|
      hash["item_#{i}"] = rand(1000)
    end
    hash
  end
end

def big_weights_hash
  @big_weights ||= begin
    hash = {}
    (1..5000).to_a.each do |i|
      hash["item_#{i}"] = rand(100_000) + 10_000
    end
    hash
  end
end

def simple(uniq=false)
  pickup = Pickup.new(simple_hash, uniq: uniq)
  pickup.pick(10)
end

def big(uniq=false)
  pickup = Pickup.new(big_hash, uniq: uniq)
  pickup.pick(100)
end

def big_weights(uniq=false)
  pickup = Pickup.new(big_weights_hash, uniq: uniq)
  pickup.pick(100)
end

n = 500

Benchmark.bm do |x|
  x.report("simple: ") do
    n.times{ simple }
  end
  x.report("simple uniq: ") do
    n.times{ simple(true) }
  end
  x.report("big: ") do
    n.times{ big }
  end
  x.report("big uniq: ") do
    n.times{ big(true) }
  end
  x.report("big weights: ") do
    n.times{ big_weights }
  end
  x.report("big weights uniq: ") do
    n.times{ big_weights(true) }
  end
end