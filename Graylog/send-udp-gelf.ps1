$udpClient = New-Object System.Net.Sockets.UdpClient
$msg = '{"version":"1.1","host":"ps-test","short_message":"hello from PowerShell UDP","level":6}'
$bytes = [System.Text.Encoding]::UTF8.GetBytes($msg)
$udpClient.Send($bytes, $bytes.Length, "localhost", 12201)
$udpClient.Close()
