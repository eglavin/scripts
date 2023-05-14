. "$PSScriptRoot\..\administrator\is-admin.ps1"

if ((IsAdmin) -eq $false) {
  Write-Error "You must run this script as administrator."

  exit
}


function Set-Interface-Dynamic {
  [CmdletBinding()]
  param (
    [Parameter()] [string] $interface
  )

  # Set the interface to use DHCP.
  netsh interface ipv4 set address $interface dhcp
  netsh interface ipv4 set dnsservers $interface dhcp

  # Show the interface configuration.
  netsh interface ipv4 show config $interface
}


Set-Interface-Dynamic -interface "Ethernet"
