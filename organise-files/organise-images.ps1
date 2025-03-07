param (
	[Parameter(Mandatory = $true)] [string] $SourcePath,
	[Parameter(Mandatory = $true)] [string] $DestinationPath,
	[switch] $Move,
	[switch] $DryRun,
	[switch] $CreateTypeFolders,
	[switch] $AllowFallbackToLastWriteTime
)


$Months = @{
	1  = "01 - January";
	2  = "02 - February";
	3  = "03 - March";
	4  = "04 - April";
	5  = "05 - May";
	6  = "06 - June";
	7  = "07 - July";
	8  = "08 - August";
	9  = "09 - September";
	10 = "10 - October";
	11 = "11 - November";
	12 = "12 - December"
}



function IsValidYear {
	param (
		[Parameter(Mandatory = $true)] [int] $Year
	)

	if ($Year -lt 1900) {
		Write-Host "Year $Year is invalid" -ForegroundColor Red
		return $false;
	}
	return $true;
}

function IsValidMonth {
	param (
		[Parameter(Mandatory = $true)] [int] $Month
	)

	if ($Month -lt 1 -or $Month -gt 12) {
		Write-Host "Month $Month is invalid" -ForegroundColor Red
		return $false;
	}
	return $true;
}

$ShellObject = New-Object -ComObject Shell.Application

function GetImageDateTaken {
	param (
		[Parameter(Mandatory = $true)] [string] $FileName,
		[Parameter(Mandatory = $true)] [string] $FilePath
	)

	try {
		$DirectoryObject = $ShellObject.NameSpace($FilePath)
		$FileObject = $DirectoryObject.ParseName($FileName)

		$Property = 'Date taken'
		for ($Index = 5;
			$DirectoryObject.GetDetailsOf($DirectoryObject.Items, $Index) -ne $Property;
			++$Index) {}

		return $DirectoryObject.GetDetailsOf($FileObject, $Index)
	}
	catch {}
}

function GetMediaCreatedDate {
	param (
		[Parameter(Mandatory = $true)] [string] $FileName,
		[Parameter(Mandatory = $true)] [string] $FilePath
	)

	try {
		$DirectoryObject = $ShellObject.NameSpace($FilePath)
		$FileObject = $DirectoryObject.ParseName($FileName)

		$Property = 'Media created'
		for ($Index = 5;
			$DirectoryObject.GetDetailsOf($DirectoryObject.Items, $Index) -ne $Property;
			++$Index) {}

		return $DirectoryObject.GetDetailsOf($FileObject, $Index)
	}
	catch {}
}

function ParseDate {
	param (
		[Parameter(Mandatory = $true)] [string] $DateString,
		[Parameter(Mandatory = $true)] [string] $Format
	)

	# Remove encoding characters
	$ReplacedDateString = $DateString -replace "\u200e|\u200f", ""

	# We only want the date
	$ReplacedDateString = $ReplacedDateString -split " " | Select-Object -First 1

	# Handle dates being returned in different formats
	try {
		return [DateTime]::ParseExact($ReplacedDateString, $Format, $null)
	}
	catch {
		Write-Error "Failed to parse date $DateString with format $Format"

		exit 1
	}
}

function RecogniseType {
	param (
		[Parameter(Mandatory = $true)] [string] $FileName
	)

	$Extension = ($FileName -split "\.").ToLower() | Select-Object -Last 1

	switch -Regex ($Extension) {
		"^jpg|jpeg|png|gif|bmp$" {
			return "image"
		}
		"^rw2|cr2$" {
			return "raw"
		}
		"^mp4|mov|avi|wmv|flv$" {
			return "video"
		}
		default {
			return "unknown"
		}
	}
}



function OrganiseImage {
	param (
		[Parameter(Mandatory = $true)] [string] $Source,
		[Parameter(Mandatory = $true)] [string] $Name,
		[Parameter(Mandatory = $true)] [string] $Date,
		[Parameter(Mandatory = $true)] [string] $Destination,
		[Parameter(Mandatory = $true)] [string] $Format
	)

	$FileDate = ParseDate -DateString $Date -Format $Format

	if (-not (IsValidYear -Year $FileDate.Year)) {
		return;
	}
	if (-not (IsValidMonth -Month $FileDate.Month)) {
		return;
	}

	$FileDestination = "$Destination\$($FileDate.Year)\$($Months[$FileDate.Month])"

	if ($CreateTypeFolders) {
		$FileType = RecogniseType -FileName $Name

		if ($FileType -eq "image") {
			$FileDestination = "$FileDestination\Images"
		}
		elseif ($FileType -eq "raw") {
			$FileDestination = "$FileDestination\Raws"
		}
		elseif ($FileType -eq "video") {
			$FileDestination = "$FileDestination\Videos"
		}
		else {
			Write-Host "File type not recognised" -ForegroundColor Red
			return;
		}
	}

	Write-Host "$($Move ? "Moving" : "Copying") to destination: `"$FileDestination`""

	if (Test-Path -Path "$FileDestination\$Name") {
		Write-Host "File already exists in destination" -ForegroundColor Cyan
		return;
	}


	if ($DryRun) {
		Write-Host "Dry run, file not $($Move ? "moved" : "copied")" -ForegroundColor Yellow
		return;
	}

	if ((Test-Path $FileDestination) -eq $false) {
		Write-Host "Creating folder $FileDestination" -ForegroundColor Yellow
		[void](New-Item -ItemType Directory -Force -Path $FileDestination)
	}

	if ($Move) {
		[void](Move-Item $Source -Destination $FileDestination)
	}
	else {
		[void](Copy-Item $Source -Destination $FileDestination)
	}
}



$Files = Get-ChildItem -Path $SourcePath -Recurse -File
Write-Host "Found $($Files.Count) files"

$Files | ForEach-Object {
	$FileSource = $_.FullName
	$FileName = $_.Name

	Write-Host "`nSource: `"$FileSource`"" -ForegroundColor Green

	# Skip files in folders with the name "edit" in it
	if ($FileSource -Match "Edit") {
		Write-Host "File exists in an edits folder" -ForegroundColor Magenta

		return;
	}

	# Sort any images or files with a Date taken property
	$imageDateTaken = GetImageDateTaken -FilePath $_.Directory.FullName -FileName $FileName

	if ($imageDateTaken) {
		OrganiseImage `
			-Source $FileSource `
			-Name $FileName `
			-Destination $DestinationPath `
			-Date $imageDateTaken `
			-Format "dd/MM/yyyy"

		return;
	}

	# Sort any videos or files with a Media created property
	$mediaCreatedDate = GetMediaCreatedDate -FilePath $_.Directory.FullName -FileName $FileName

	if ($mediaCreatedDate) {
		OrganiseImage `
			-Source $FileSource `
			-Name $FileName `
			-Destination $DestinationPath `
			-Date $mediaCreatedDate `
			-Format "dd/MM/yyyy"

		return;
	}

	# Fall back to sorting by last write time
	if ($AllowFallbackToLastWriteTime) {
		OrganiseImage `
			-Source $FileSource `
			-Name $FileName `
			-Destination $DestinationPath `
			-Date $File.LastWriteTime `
			-Format "MM/dd/yyyy"
	}
	else {
		Write-Host "Not falling back to last write time" -ForegroundColor Cyan
	}
}
