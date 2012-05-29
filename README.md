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
Values are a chence to get this fish.

So we should create our pickup.

```ruby
pickup = Pickup.new(pond)
pickup.pick(3)
#=> [ "gudgeon", "minnow", "minnow" ]
```
Look, we've just catched few minnows! To get selmon we need some more tries ;)

Ok. What if our probability is not a linear function. We can create our pickup with a function:

```ruby
pickup = Pickup.new(pond){ |v| v**2 }
pickup.pick(3)
#=> ["carp", "selmon", "crucian"]
```
Wow, good catch!

Also you can change our `function` on the fly. Let's make square function:

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
