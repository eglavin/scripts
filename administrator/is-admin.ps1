# https://learn.microsoft.com/en-us/dotnet/api/system.security.principal.windowsidentity.getcurrent?view=net-7.0
# https://learn.microsoft.com/en-us/dotnet/api/system.security.principal.windowsprincipal?view=net-8.0

function IsAdmin {
  $currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent();

  return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
}