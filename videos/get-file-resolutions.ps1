param (
	[Parameter(Mandatory = $true)] [string] $path,
	[Parameter(Mandatory = $false)] [string] $outputFile = ""
)

# Create script timer
$timer = [Diagnostics.Stopwatch]::StartNew()

# List of known video file extensions
$knownVideosFileExtensions = @(
	".avi",
	".m4v",
	".mkv",
	".mov",
	".mp4",
	".wmv"
);


# Test if ffprobe is installed from ffmpeg
$hasFFprobe = $null -ne (Get-Command -Name ffprobe -ErrorAction SilentlyContinue)

# Use shell object application to get video properties
$shellObject = New-Object -ComObject Shell.Application
function GetVideoProperty {
	param (
		[string] $fileName,
		[string] $filePath,
		[string] $property
	)

	try {
		$directoryObject = $shellObject.NameSpace($filePath)
		$fileObject = $directoryObject.ParseName($fileName)

		for ($index = 0;
			$directoryObject.GetDetailsOf($directoryObject.Items, $index) -ne $property;
			++$index) {}

		return $directoryObject.GetDetailsOf($fileObject, $index)
	}
	catch {}
}


$files = Get-ChildItem -Path $path -File -Recurse `
| Where-Object { $knownVideosFileExtensions.Contains($_.Extension.ToLower()) } `
| Sort-Object -Property DirectoryName
$output = [System.Collections.ArrayList]@()


foreach	( $file in $files ) {
	if ($hasFFprobe) {
		$ffprobeOutput = (ffprobe `
				-v error `
				-select_streams v `
				-show_entries stream=width,height `
				-of json "$($file.FullName)") | ConvertFrom-Json

		$width = $ffprobeOutput.streams[0].width
		$height = $ffprobeOutput.streams[0].height
	}
	else {
		$width = GetVideoProperty `
			-filePath $file.Directory.FullName `
			-fileName $file.Name `
			-property 'Frame width'
		$height = GetVideoProperty `
			-filePath $file.Directory.FullName `
			-fileName $file.Name `
			-property 'Frame height'
	}

	# Add to output if resolution is less than 1920 width or 1080 height
	# if ([int]$width -lt 1919 -or [int]$height -lt 1079) {
	if ([int]$width -lt 1919 -and [int]$height -lt 1079) {
		$fileInfo = [Ordered] @{
			"Name"      = $file.BaseName
			"Extension" = $file.Extension.Replace(".", "")
			"Path"      = $file.DirectoryName
			"Size"      = "{0} GB" -f [math]::Round($file.Length / 1GB, 2)
			"Width"     = $width
			"Height"    = $height
		}

		[void]$output.Add($fileInfo)

		# if ($output.Count -eq 10) {
		# 	break;
		# }
	}
}


# Convert to JSON and output to file
$jsonOutput = $output | ConvertTo-Json -depth 100
if ($outputFile -ne "") {
	$jsonOutput | Out-File $outputFile
}


# Output to console
$jsonOutput `
| ConvertFrom-Json `
| Select-Object Name, Extension, Size, Width, Height `
| Format-Table -AutoSize


Write-Host "Total files: $($output.Count)"


# Stop timer and output elapsed time
$timer.stop()
Write-Host "Elapsed time: $([math]::Round($timer.Elapsed.TotalSeconds, 2)) seconds"
