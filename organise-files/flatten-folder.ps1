param (
	[Parameter(Mandatory = $true)] [string] $sourcePath
)

Get-ChildItem -Path $sourcePath -File -Recurse | Move-Item -Destination $sourcePath
