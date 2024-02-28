# Extracts unique frames from the given video file.
#
# Ref: https://superuser.com/questions/1296702/get-snapshots-of-only-changed-frames-using-ffmpeg

param (
	[Parameter(Mandatory = $true)] [string] $file
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
	-vsync vfr `
	-filter_complex "select=gt(scene\,0.07)" `
	"$outputPath\%07d.jpg"
