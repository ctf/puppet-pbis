# Fact: netbois_domain_name
#
# Purpose:
# Return the NetBIOS domain name of the domain that the machine is joined to 
# with PBIS
#
# Resolution:
# Parse output of /opt/pbis/bin/lsa ad-get-machine account and report the value
#
# Caveats:
# Linux only
#
# Author: Ben Woods <woodsbw@gmail.com>
Facter.add(:netbois_domain_name) do
  has_weight 100
  setcode do
    if File.exist? '/opt/pbis/bin/lsa'
      line_output = `/opt/pbis/bin/lsa ad-get-machine account | grep 'NetBIOS Domain Name'`.to_s.split(":")
      data_to_return = line_output[1].to_s.strip
      data_to_return
    end
  end
end

Facter.add(:netbois_domain_name) do
  setcode do
    'not defined'
  end
end
