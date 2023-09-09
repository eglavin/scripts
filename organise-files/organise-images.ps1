param (
	[Parameter(Mandatory = $true)] [string] $sourcePath,
	[Parameter(Mandatory = $true)] [string] $destinationPath,
	[switch] $move
)


if ((Test-Path $destinationPath) -eq $false) {
	Write-Host "Creating destination path $destinationPath" -ForegroundColor Green
	$out = New-Item -ItemType Directory -Force -Path $destinationPath
}

$months = @{
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

Function CreateYearFolder {
	param (
		[Parameter(Mandatory = $true)] [string] $path,
		[Parameter(Mandatory = $true)] [int] $year
	)

	if ($year -lt 1900) {
		Write-Host "Year $year is invalid" -ForegroundColor Red
		return
	}

	$yearPath = "$path\$year"

	if ((Test-Path $yearPath) -eq $false) {
		Write-Host "Creating folder $yearPath" -ForegroundColor Green
		$out = New-Item -ItemType Directory -Force -Path $yearPath
	}
}

Function CreateMonthSubFolder {
	param (
		[Parameter(Mandatory = $true)] [string] $path,
		[Parameter(Mandatory = $true)] [int] $month
	)

	if ($month -lt 1 -or $month -gt 12) {
		Write-Host "Month $month is invalid" -ForegroundColor Red
		return
	}

	$monthPath = "$path\$($months[$month])"

	if ((Test-Path $monthPath) -eq $false) {
		Write-Host "Creating folder $monthPath" -ForegroundColor Green
		$out = New-Item -ItemType Directory -Force -Path $monthPath
	}
}

Function GetImageDateTaken {
	param (
		[Parameter(Mandatory = $true)] [string] $fileName,
		[Parameter(Mandatory = $true)] [string] $filePath
	)

	try {
		$shellObject = New-Object -ComObject Shell.Application

		$directoryObject = $shellObject.NameSpace($filePath)
		$fileObject = $directoryObject.ParseName($fileName)

		$property = 'Date taken'
		for ($index = 5;
			$directoryObject.GetDetailsOf($directoryObject.Items, $index) -ne $property;
			++$index) {}

		return $directoryObject.GetDetailsOf($fileObject, $index)
	}
	catch {}
}

Function GetMediaCreatedDate {
	param (
		[Parameter(Mandatory = $true)] [string] $fileName,
		[Parameter(Mandatory = $true)] [string] $filePath
	)

	try {
		$shellObject = New-Object -ComObject Shell.Application

		$directoryObject = $shellObject.NameSpace($filePath)
		$fileObject = $directoryObject.ParseName($fileName)

		$property = 'Media created'
		for ($index = 5;
			$directoryObject.GetDetailsOf($directoryObject.Items, $index) -ne $property;
			++$index) {}

		return $directoryObject.GetDetailsOf($fileObject, $index)
	}
	catch {}
}

Function ParseDate {
	param (
		[Parameter(Mandatory = $true)] [string] $dateString,
		[Parameter(Mandatory = $true)] [string] $format
	)

	# Remove encoding characters
	$replacedDateString = $dateString -replace "\u200e|\u200f", ""

	# We only want the date
	$replacedDateString = $replacedDateString -split " " | Select-Object -First 1

	# Handle dates being returned in different formats
	try {
		return [DateTime]::ParseExact($replacedDateString, $format, $null)
	}
	catch {
		Write-Error "Failed to parse date $dateString with format $format"
		exit
	}
}



Function OrganiseImage {
	param (
		[Parameter(Mandatory = $true)] [string] $name,
		[Parameter(Mandatory = $true)] [string] $date,
		[Parameter(Mandatory = $true)] [string] $meta,
		[Parameter(Mandatory = $true)] [string] $source,
		[Parameter(Mandatory = $true)] [string] $destination,
		[Parameter(Mandatory = $true)] [string] $format
	)

	Write-Host "`nOrganising $name" -ForegroundColor Green
	Write-Host "$meta`: $date"

	$fileDate = ParseDate -dateString $date -format $format
	$fileYear = $fileDate.Year
	$fileMonth = $fileDate.Month


	CreateYearFolder -path $destination -year $fileYear
	CreateMonthSubFolder -path "$destination\$fileYear" -month $fileMonth


	$filePath = "$source\$name"
	$fileDestination = "$destination\$fileYear\$($months[$fileMonth])"


	Write-Host "Source: $filePath -> Destination: $fileDestination"
	if (Get-ChildItem -Path $fileDestination $name) {
		Write-Host "File already exists in destination" -ForegroundColor Yellow
	}
	else {
		if ($move) {
			Move-Item $filePath -Destination $fileDestination
		}
		else {
			Copy-Item $filePath -Destination $fileDestination
		}
	}
}



$files = Get-ChildItem -Path $sourcePath -File

ForEach ($file in $files) {
	# Sort any images or files with a Date taken property
	$imageDateTaken = GetImageDateTaken -filePath $file.Directory.FullName -fileName $file.Name
	if ($imageDateTaken) {
		OrganiseImage -name $file.Name -date $imageDateTaken -meta "Date taken" -source $sourcePath -destination $destinationPath -format "dd/MM/yyyy"

		continue;
	}

	# Sort any videos or files with a Media created property
	$mediaCreatedDate = GetMediaCreatedDate -filePath $file.Directory.FullName -fileName $file.Name
	if ($mediaCreatedDate) {
		OrganiseImage -name $file.Name -date $mediaCreatedDate -meta "Media created" -source $sourcePath -destination $destinationPath -format "dd/MM/yyyy"

		continue;
	}

	# Fall back to sorting by last write time
	OrganiseImage -name $file.Name -date $file.LastWriteTime -meta "Last write" -source $sourcePath -destination $destinationPath -format "MM/dd/yyyy"
}
