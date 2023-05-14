. "$PSScriptRoot\..\administrator\is-admin.ps1"

if ((IsAdmin) -eq $false) {
  Write-Error "You must run this script as administrator."

  exit
}


function Set-Interface-Static {
  [CmdletBinding()]
  param (
    [Parameter()] [string] $interface,
    [Parameter()] [string] $ipAddress,
    [Parameter()] [string] $mask,
    [Parameter()] [string] $gateway,
    [Parameter()] [string[]] $dnsServers
  )

  # Set the interface to use the specified IP address.
  netsh interface ipv4 set address $interface static $ipAddress $mask $gateway

  # Set the interface to use the specified DNS servers.
  for ($index = 0; $index -lt $dnsServers.Count; $index++) {
    $dnsServer = $dnsServers[$index]

    netsh interface ipv4 add dnsserver $interface $dnsServer
  }

  # Show the interface configuration.
  netsh interface ipv4 show config $interface
}


Set-Interface-Static `
  -interface "Ethernet" `
  -ipAddress "192.168.1.175" `
  -mask "255.255.255.0" `
  -gateway "192.168.1.254" `
  -dnsServers @("8.8.8.8", "1.1.1.1")
