[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)] [string] $location,
  [Parameter()] [string] $token,
  [Parameter()] [string] $user
)


function Get-AllReposForAuthenticatedUser {
  param(
    [Parameter(Mandatory = $true)] [string] $userToken
  )

  # Documentation: https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user
  $url = "https://api.github.com/user/repos?per_page=100"
  $headers = @{
    "Accept"               = "application/vnd.github+json";
    "X-GitHub-Api-Version" = "2022-11-28";
    "Authorization"        = "Bearer $userToken"
  }

  $response = Invoke-WebRequest -Uri $url -Headers $headers
  $repositories = $response.Content | ConvertFrom-Json

  return $repositories
}

function Get-AllReposForUser {
  param(
    [Parameter(Mandatory = $true)] [string] $userName
  )

  # Documentation: https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
  $url = "https://api.github.com/users/$userName/repos?per_page=100"
  $headers = @{
    "Accept"               = "application/vnd.github+json";
    "X-GitHub-Api-Version" = "2022-11-28";
  }

  $response = Invoke-WebRequest -Uri $url -Headers $headers
  $repositories = $response.Content | ConvertFrom-Json

  return $repositories
}

function Download-Repo {
  param(
    [Parameter(Mandatory = $true)] [string] $repoCloneUrl,
    [Parameter(Mandatory = $true)] [string] $repoName
  )

  $cloneToLocation = "$(Resolve-Path $location)\$repoName"

  if (Test-Path $cloneToLocation) {
    Write-Host "Repository $repoName already exists"
  }
  else {
    Write-Host "Cloning Project: $repoName From: $repoCloneUrl Into: $cloneToLocation"

    git clone $repoCloneUrl $cloneToLocation
  }
}



# If we have a token, use it to get all repositories for the authenticated user
# Otherwise, use the username to get public repositories for the user
if ($token) {
  $repos = Get-AllReposForAuthenticatedUser -userToken $token
}
else {
  $repos = Get-AllReposForUser -userName $user
}


if ($null -eq $repos) {
  Write-Host "No repositories found"
  exit
}


foreach ($repo in $repos) {
  Download-Repo -repoCloneUrl $repo.clone_url -repoName $repo.name
}
