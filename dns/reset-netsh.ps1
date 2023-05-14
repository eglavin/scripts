. "$PSScriptRoot\..\administrator\is-admin.ps1"

if ((IsAdmin) -eq $false) {
  Write-Error "You must run this script as administrator."

  exit
}

netsh interface ip reset
