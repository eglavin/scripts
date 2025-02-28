param (
	[Parameter(Mandatory = $true)] [string] $OldName,
	[Parameter(Mandatory = $true)] [string] $NewName,
	[string] $Path = "."
)

Get-ChildItem -Path $Path -Directory -Recurse | ForEach-Object {
	$Folder = $_
	$FolderLocation = $Folder.Parent.FullName
	$FolderName = $Folder.Name

	if ($FolderName -eq $OldName) {
		$NewFolderName = "$FolderLocation\$NewName"

		Write-Host "Renaming folder from: $Folder to $NewFolderName"

		$Folder | Rename-Item -NewName $NewFolderName
	}
}
