param (
	[string]$source = "",
	[string]$destination = ""
)

$resourceSource = $source + "\resources"
$scriptSource = $source + "\scripts"

$zipName = $destination + "\data.zip"
$binName = $destination + "\data.bin"

Compress-Archive -Path $resourceSource -DestinationPath $zipName -Force
Compress-Archive -Path $scriptSource -DestinationPath $zipName -Update

if (Test-Path $binName)
{
	Remove-Item $binName
}

Rename-Item -Path $zipName -NewName $binName