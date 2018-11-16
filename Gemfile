# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

def component(name)
  if ENV['CI']
    gem "ephesus-#{name}",
      git: "https://github.com/sleepingkingstudios/ephesus-#{name}"
  else
    gem "ephesus-#{name}", path: "../#{name}"
  end
end

gem 'bronze', git: 'https://github.com/sleepingkingstudios/bronze'

gem 'cuprum', git: 'https://github.com/sleepingkingstudios/cuprum'

gem 'patina', git: 'https://github.com/sleepingkingstudios/bronze'

gem 'zinke', git: 'https://github.com/sleepingkingstudios/zinke'

component :core
