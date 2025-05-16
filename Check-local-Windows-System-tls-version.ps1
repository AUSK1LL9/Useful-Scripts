$CheckTLS10 = [Net.ServicePointManager]::SecurityProtocol
if ($CheckTLS10 -band [Net.SecurityProtocolType]::Tls10) {
    Write-Output "TLS 1.0 is enabled."
}
$CheckTLS11 = [Net.ServicePointManager]::SecurityProtocol
if ($CheckTLS11 -band [Net.SecurityProtocolType]::Tls11) {
    Write-Output "TLS 1.1 is enabled."
}
$CheckTLS12 = [Net.ServicePointManager]::SecurityProtocol
if ($CheckTLS12 -band [Net.SecurityProtocolType]::Tls12) {
    Write-Output "TLS 1.2 is enabled."
}
$CheckTLS13 = [Net.ServicePointManager]::SecurityProtocol
if ($CheckTLS13 -band [Net.SecurityProtocolType]::Tls13) {
    Write-Output "TLS 1.3 is enabled."
}
