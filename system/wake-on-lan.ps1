param(
	[Parameter(Mandatory = $true)] [string] $MacAddress
)

$ByteArray = $MacAddress -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
$MagicPacket = [Byte[]](,0xFF * 6) + ($ByteArray * 16)

$UDPClient = New-Object System.Net.Sockets.UdpClient
$UDPClient.Connect(([System.Net.IPAddress]::Broadcast), 7)
$UDPClient.Send($MagicPacket, $MagicPacket.Length)
$UDPClient.Close()
