# Fact: boot_partition_uuid
#
# Purpose:
# Return the UUID of the EFI boot partition
#
# Resolution:
# Parse output of blkid, as well as do some test mounting to find the parition
#
# Caveats:
# Linux only
#
# Author: Ben Woods <woodsbw@gmail.com>
Facter.add(:domain_dns_name) do
  setcode do
    line_output = `/opt/pbis/bin/lsa ad-get-machine account | grep 'DNS Domain Name'`.split(":")
    data_to_return = line_output[1].strip
    data_to_return
  end
end