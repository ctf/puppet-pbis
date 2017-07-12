require 'simplecov'
require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'


SimpleCov.start do
  add_filter '/spec/'
  # Exclude bundled Gems in `/.vendor/`
  add_filter '/.vendor/'
end

RSpec.configure do |c|
  c.default_facts = {
      :puppetversion          => '4.5.3',
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7',
      :architecture           => "x86_64",
      :concat_basedir         => '/var/lib/puppet/concat',
      :kernel                 => 'Linux'
  }
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end