#!/usr/bin/env ruby

module Puppet::Parser::Functions
  newfunction(:transform_ou, :type => :rvalue) do |args|
    # e.g. ou=Computers,ou=Department,ou=Division
    ou = args[0]
    # Convert to ['Divison', 'Department', 'Computers']
    ou = ou.gsub('ou=','')
    ou = ou.split(',')
    ou = ou.reverse()
    # Convert to an OU 'path'
    ou.join('/')
  end
end
