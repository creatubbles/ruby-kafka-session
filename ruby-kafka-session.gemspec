# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name        = "ruby-kafka-session"
  gem.version     = '0.1'
  gem.date        = '2017-01-10'
  gem.authors     = ['James M.C. Haver II']
  gem.email       = ['james@creatubbles.com']
  gem.summary     = %q{Start a kafka session.}
  gem.description = %q{Start a kafka session.}
  gem.homepage    = ''
  gem.license     = ''
  gem.files         = ['lib/ruby-kafka-session.rb']
  gem.require_paths = ['lib']
end
