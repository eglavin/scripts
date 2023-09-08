param (
	[Parameter(Mandatory = $true)] [string] $path
)

$months = @("01 - January",
	"02 - February",
	"03 - March",
	"04 - April",
	"05 - May",
	"06 - June",
	"07 - July",
	"08 - August",
	"09 - September",
	"10 - October",
	"11 - November",
	"12 - December")

# Test if containing path exists
if (Test-Path $path) {
	Write-Host "Folder $path already exists"
}
else {
	Write-Host "Creating folder $path"
	New-Item -ItemType Directory -Force -Path $path
}

# Loop through months and create folders
ForEach ($month in $months) {
	$monthPath = "$path\$month"

	if (Test-Path $monthPath) {
		Write-Host "Folder $monthPath already exists"
	}
	else {
		Write-Host "Creating folder $monthPath"
		New-Item -ItemType Directory -Force -Path $monthPath
	}
}
