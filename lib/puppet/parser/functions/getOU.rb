#!/usr/bin/env ruby

module Puppet::Parser::Functions
  newfunction(:getOU, :type => :rvalue) do |args|
    # e.g. ou=Computers,ou=Department,ou=Division
    ou = args[0]
    # Convert to ['Divison', 'Department', 'Computers']
    ou.gsub('ou=','')
    ou = ou.reverse()
    # Convert to an OU 'path'
    ou.join('/')
  end
end
