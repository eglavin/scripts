# Extracts a duration from the given video file.
#
# Example extract 10 minutes from the 02:10:00 starting point:
# .\extract-time-duration.ps1 video.mp4 -start 02:10:00 -duration 0:10:00
#
# Ref: https://www.arj.no/2018/05/18/trimvideo

param (
	[Parameter(Mandatory = $true)] [string] $file,
	[Parameter(Mandatory = $true)] [string] $start,
	[Parameter(Mandatory = $true)] [string] $duration
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
	-t $duration `
	-c:v copy `
	-c:a copy `
	$outputFileName
