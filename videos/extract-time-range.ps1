# Extracts a time range from the given video file.
#
# Example extract from 02:10:00 to 03:10:00:
# .\extract-time-range.ps1 video.mp4 -start 02:10:00 -end 03:10:00
#
# Ref: https://www.arj.no/2018/05/18/trimvideo

param (
	[Parameter(Mandatory = $true)] [string] $file,
	[Parameter(Mandatory = $true)] [string] $start,
	[Parameter(Mandatory = $true)] [string] $end
)

$filePath = Split-Path -Path $file
$fileName = Split-Path -Path $file -LeafBase
$fileExtension = Split-Path -Path $file -Extension

$outputFileName = "$filePath\$fileName - Trimmed$fileExtension";

if (Test-Path $outputFileName) {
	Write-Error "File already exists: $outputFileName"
	exit 1;
}

ffmpeg `
	-i $file `
	-ss $start `
	-to $end `
	-c:v copy `
	-c:a copy `
	$outputFileName
