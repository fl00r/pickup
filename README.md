# Pickup

Pickup helps you to pick item from collection by it's weight/probability

## Installation

Add this line to your application's Gemfile:

    gem 'pickup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pickup

## Usage

For example, we have got a pond with fish.

```ruby
pond = {
  "selmon"  => 1,
  "carp" => 4,
  "crucian"  => 3,
  "herring" => 6,
  "sturgeon" => 8,
  "gudgeon" => 10,
  "minnow" => 20
}
```
Values are a chance (probability) to get this fish.

So we should create our pickup.

```ruby
pickup = Pickup.new(pond)
pickup.pick(3)
#=> [ "gudgeon", "minnow", "minnow" ]
```
Look, we've just catched few minnows! To get selmon we need some more tries ;)

### Custom distribution function

Ok. What if our probability is not a linear function. We can create our pickup with a function:

```ruby
pickup = Pickup.new(pond){ |v| v**2 }
pickup.pick(3)
#=> ["carp", "selmon", "crucian"]
```
Wow, good catch!

Also you can change our "function" on the fly. Let's make square function:

```ruby
pickup = Pickup.new(pond)
pickup.pick_func = Proc.new{ |v| v**2 }
```
Or you can pass a block as a probability function wich will be applicable only to current operation

```ruby
pickup = Pickup.new(pond)
pickup.pick{ |v| Math.sin(v) } # same as pickup.pick(1){ ... }
#=> "selmon"
pickup.pick
#=> "minnow"
```

In case of `f(weight)=weight^10` most possible result will be "minnow", because `20^10` is `2^10` more possible then "gudgeon"

```ruby
pickup = Pickup.new(pond)
pickup.pick(10){ |v| v**10 }
#=> ["minnow", "minnow", "minnow", "minnow", "minnow", "minnow", "minnow", "minnow", "minnow", "minnow"]
```

Or you can use reverse probability:

```ruby
pickup = Pickup.new(pond)
pickup.pick(10){ |v| v**(-10) }
#=> ["selmon", "selmon", "selmon", "selmon", "crucian", "selmon", "selmon", "selmon", "selmon", "selmon"]
```

### Random uniq pick

Also we can pick random uniq items from the list

```ruby
pickup = Pickup.new(pond, uniq: true)
pickup.pick(3)
#=> [ "gudgeon", "herring", "minnow" ]
pickup.pick
#=> "herring"
pickup.pick
#=> "gudgeon"
pickup.pick
#=> "sturgeon"
```

### Custom key and weight selection functions

We can use more complex collections by defining our own key and weight selectors:

```ruby
require "ostruct"

pond_ostruct = [
  OpenStruct.new(key: "sel", name: "selmon", weight: 1),
  OpenStruct.new(key: "car", name: "carp", weight: 4),
  OpenStruct.new(key: "cru", name: "crucian", weight: 3),
  OpenStruct.new(key: "her", name: "herring", weight: 6),
  OpenStruct.new(key: "stu", name: "sturgeon", weight: 8),
  OpenStruct.new(key: "gud", name: "gudgeon", weight: 10),
  OpenStruct.new(key: "min", name: "minnow", weight: 20)
]

key_func = Proc.new{ |item| item.key }
weight_func = Proc.new{ |item| item.weight }

pickup = Pickup.new(pond_ostruct, key_func: key_func, weight_func: weight_func)
pickup.pick
#=> "gud"

name_func = Proc.new{ |item| item.name }
pickup.pick(1, key_func: name_func)
#=> "gudgeon"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request