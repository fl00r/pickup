# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pickup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["fl00r"]
  gem.email         = ["fl00r@yandex.ru"]
  gem.description   = %q{Pickup helps you to pick item from collection by it's weight/probability}
  gem.summary       = %q{Pickup helps you to pick item from collection by it's weight/probability}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pickup"
  gem.require_paths = ["lib"]
  gem.version       = Pickup::VERSION
end
