param (
	[Parameter(Mandatory = $true)] [string] $Path = ".",
	[switch] $DeleteEmptyFolders
)

Get-ChildItem -Path $Path -Directory -Recurse | ForEach-Object {
	$Folder = $_

	if ((Get-ChildItem -Path $Folder.FullName).Count -eq 0) {
		Write-Host "Empty folder: $Folder"

		if ($DeleteEmptyFolders) {
			Write-Host "Deleting folder: $Folder"
			$Folder | Remove-Item
		}
	}
}
