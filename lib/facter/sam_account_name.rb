# Fact: sam_account_name
#
# Purpose:
# Return the SAM account name of the domain that the machine is joined to 
# with PBIS
#
# Resolution:
# Parse output of /opt/pbis/bin/lsa ad-get-machine account and report the value
#
# Caveats:
# Linux only
#
# Author: Ben Woods <woodsbw@gmail.com>
Facter.add(:sam_account_name) do
  setcode do
    line_output = `/opt/pbis/bin/lsa ad-get-machine account | grep 'SAM Account Name'`.split(":")
    data_to_return = line_output[1].strip
    data_to_return
  end
end
