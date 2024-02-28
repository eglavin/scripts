# Extracts images from the given video, the default is
# to extract one frame for each second.
#
# Using the -fps parameter you can specify the number of frames:
# `-fps 1/60` is every minute at 60 frames per second.
# `-fps 1/600` is every 10 minutes at 60 frames per second.

param (
	[Parameter(Mandatory = $true)] [string] $file,
	[Parameter(Mandatory = $false)] [string] $fps = "1"
)

$filePath = Split-Path -Path $file
$currentDateTime = Get-Date -Format "yyyy_MM_dd HH_mm_ss"

$outputPath = "$filePath\Output $currentDateTime"

if ((Test-Path $outputPath) -eq $false) {
	New-Item -ItemType Directory -Path $outputPath
}
else {
	Write-Error "The output directory already exists: $outputPath"
	exit 1;
}

ffmpeg `
	-i $file `
	-vf fps=$fps `
	"$outputPath\%07d.jpg"
