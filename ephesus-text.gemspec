# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'ephesus/text/version'

Gem::Specification.new do |gem|
  gem.name        = 'ephesus-text'
  gem.version     = Ephesus::Text::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary     = 'Text commands and utilities for Ephesus applications.'

  description = <<~DESCRIPTION
    Commands and utilities for building text-based Ephesus applications.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'GPL-3.0'

  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'ephesus-core'
  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 0.7'

  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '>= 2.4.1'
  gem.add_development_dependency 'rubocop', '~> 0.60.0'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.30.1'
  gem.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'
  gem.add_development_dependency 'thor', '~> 0.20'
end
