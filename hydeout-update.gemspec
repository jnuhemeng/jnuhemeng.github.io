# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'hydeout-update'
  spec.version       = '1.0.1'
  spec.author        = 'Marcus'
  spec.summary       = %q{This gem updates Hydeout(https://github.com/fongandrew/hydeout).}
  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(assets|_(includes|layouts|sass)/|(LICENSE|README)((\.(txt|md|markdown)|$)))}i)
  end
  
  spec.license       = "MIT"
  spec.metadata["plugin_type"] = "theme"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_runtime_dependency "jekyll", "~> 4.2.0"
  spec.add_runtime_dependency "jekyll-gist", "~> 1.5.0"
  spec.add_runtime_dependency "jekyll-paginate", "~> 1.1.0"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.15.1"
  spec.add_development_dependency "bundler", "~> 2.2.5"
end
