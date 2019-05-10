require_relative 'lib/can4/version'

Gem::Specification.new do |s|
  s.name          = 'can4'
  s.version       = Can4::VERSION
  s.author        = 'Liam P. White'
  s.email         = 'liamwhite@users.noreply.github.com'
  s.homepage      = 'https://github.com/liamwhite/can4'
  s.summary       = 'Opinionated ACL framework'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rails'
end
