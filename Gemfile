source "https://rubygems.org"

gem 'puppetlabs_spec_helper'
gem 'rspec-expectations', "2.11.3"
gem 'mocha', "0.10.5"

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
