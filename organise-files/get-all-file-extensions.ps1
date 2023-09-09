param (
	[Parameter(Mandatory = $true)] [string] $sourcePath
)

Get-ChildItem -Path $sourcePath -File -Recurse | Group-Object -Property Extension | Select-Object -ExpandProperty Name