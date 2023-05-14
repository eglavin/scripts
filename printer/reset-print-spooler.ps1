param (
  [Parameter()] [switch] $keepExistingJobs
)

. "$PSScriptRoot\..\administrator\is-admin.ps1"

if ((IsAdmin) -eq $false) {
  Write-Error "You must run this script as administrator."

  exit
}


net stop spooler

if ($keepExistingJobs -eq $false) {
  Write-Host "Removing print jobs...`n"

  Remove-Item -Force -Recurse -Confirm:$false $env:systemroot\System32\spool\PRINTERS\*
}

net start spooler
