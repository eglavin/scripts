param (
	[string] $InputDir,
	[string] $OutputDir
)

if (-not $InputDir) {
	Write-Error "Please provide the input directory containing .flac files."
	exit 1
}

if (-not $OutputDir) {
	Write-Error "Please provide the output directory for the converted .m4a files."
	exit 1
}

if (Test-Path -Path $OutputDir) {
	Write-Error "Output directory already exists."
	exit 1
}

if (-not (Test-Path -Path $OutputDir)) {
	New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Get-ChildItem -Path $InputDir -Filter *.flac | ForEach-Object {
	# Construct the absolute path for the new .m4a file
	$OutputFile = Join-Path -Path $OutputDir -ChildPath "$($_.BaseName).m4a"

	Write-Host "Converting: $($_.Name) -> $($_.BaseName).m4a" -ForegroundColor Cyan

	# Run FFmpeg with artwork and metadata preservation flags
	ffmpeg -i $_.FullName -c:a alac -c:v copy -map_metadata 0 $OutputFile
}

Write-Host "All files converted successfully!" -ForegroundColor Green
