# Fact: domain_sid
#
# Purpose:
# Return the domain SID of the domain that the machine is joined to 
# with PBIS
#
# Resolution:
# Parse output of /opt/pbis/bin/lsa ad-get-machine account and report the value
#
# Caveats:
# Linux only
#
# Author: Ben Woods <woodsbw@gmail.com>
Facter.add(:domain_sid) do
  setcode do
    line_output = `/opt/pbis/bin/lsa ad-get-machine account | grep 'Domain SID'`.split(":")
    data_to_return = line_output[1].strip
    data_to_return
  end
end
