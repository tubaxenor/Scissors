Gem::Specification.new do |s|
  s.name        = 'scissors'
  s.version     = '0.0.0'
  s.date        = '2012-06-10'
  s.summary     = "cut the crap out"
  s.description = "A nokogiri based html parser gem"
  s.authors     = ["Wei-fong Chang"]
  s.email       = 'xenor@codegreenit.com'
  s.require_paths = %w[lib]
  s.files       = %w[
                lib/scissors.rb
                lib/netfix.rb
                  ]
  s.homepage    =
    ''
  s.add_runtime_dependency('nokogiri', "~> 1.5.3")
end
