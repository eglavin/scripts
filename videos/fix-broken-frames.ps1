<#
https://stackoverflow.com/a/45465730/9325206

With re-encoding:
ffmpeg -y -i seeing_noaudio.mp4 -vf "setpts=1.25*PTS" -r 24 seeing.mp4

Without re-encoding:
First step - extract video to raw bitstream
ffmpeg -y -i seeing_noaudio.mp4 -c copy -f h264 seeing_noaudio.h264
Remux with new framerate
ffmpeg -y -r 24 -i seeing_noaudio.h264 -c copy seeing.mp4
#>

param (
	[Parameter(Mandatory = $true)] [string] $Path
)

$InputPath = "$Path\Input"
$IntermediaryPath = "$Path\Intermediary"
$OutputPath = "$Path\Output"

if (-not (Test-Path -Path $IntermediaryPath)) New-Item -Path $IntermediaryPath -ItemType Directory | Out-Null
if (-not (Test-Path -Path $OutputPath)) New-Item -Path $OutputPath -ItemType Directory | Out-Null

$InputItems = Get-ChildItem -Path $InputPath -Filter "*.mp4" -File
Write-Host "Input Items: $($InputItems.Count)"

foreach ($InputItem in $InputItems) {
	$InputItemName = $InputItem.Name

	Write-Host "Input Item: $InputItemName"

	ffmpeg `
		-y `
		-i $InputItem.FullName `
		-c copy `
		-f h264 "$IntermediaryPath\$InputItemName"

	ffmpeg `
		-y `
		-i $InputItem.FullName `
		-vn `
		-acodec copy "$IntermediaryPath\$($InputItem.BaseName).aac"

	ffmpeg `
		-y `
		-r 24 `
		-i "$IntermediaryPath\$InputItemName" `
		-i "$IntermediaryPath\$($InputItem.BaseName).aac" `
		-c copy "$OutputPath\$InputItemName"

	Write-Host "`n`n"
}

Remove-Item -Path $IntermediaryPath -Recurse -Force
