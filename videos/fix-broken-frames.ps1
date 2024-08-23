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
		-r 24 `
		-i "$IntermediaryPath\$InputItemName" `
		-c copy "$OutputPath\$InputItemName"

	Write-Host "`n`n"
}

Remove-Item -Path $IntermediaryPath -Recurse -Force