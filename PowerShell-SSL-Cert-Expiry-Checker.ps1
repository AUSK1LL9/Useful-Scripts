# Set Paths - Ensure these are correct
$inputFiles = "C:\Temp\ips.txt"
$outputFile = "C:\Temp\CertResults.csv"

# FORCE TLS Support (1.2 and 1.3)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$results = @()
$port = 443

if (Test-Path $inputFiles) {
    foreach ($ip in Get-Content $inputFiles) {
        $ip = $ip.Trim()
        if ([string]::IsNullOrWhiteSpace($ip)) { continue }

        $status = "Success"
        $reason = "Valid"
        $color = "Green"
        $certData = $null

        try {
            # Use a timeout of 2 seconds for the connection
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connection = $tcpClient.BeginConnect($ip, $port, $null, $null)
            $wait = $connection.AsyncWaitHandle.WaitOne(2000, $false)

            if (-not $wait) {
                throw "Connection Timeout"
            }

            $tcpClient.EndConnect($connection)

            # The Callback ($true) tells PowerShell: "I don't care if the cert is untrusted, just let me read it"
            $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
            $sslStream.AuthenticateAsClient($ip)
            $cert = $sslStream.RemoteCertificate
            $tcpClient.Close()

            if ($cert) {
                $expiryDate = [DateTime]::Parse($cert.GetExpirationDateString())
                $issuer = $cert.Issuer
                $subject = $cert.Subject

                if ($subject -eq $issuer) {
                    $status = "Fail"
                    $reason = "Self-Signed"
                    $color = "Red"
                }
                elseif ($expiryDate -lt (Get-Date)) {
                    $status = "Fail"
                    $reason = "Expired"
                    $color = "Red"
                }

                $certData = [PSCustomObject]@{
                    IPAddress  = $ip
                    Status     = $status
                    Reason     = $reason
                    ExpiryDate = $expiryDate
                    Issuer     = $issuer
                }
            }
        }
        catch {
            $certData = [PSCustomObject]@{
                IPAddress  = $ip
                Status     = "Fail"
                Reason     = $_.Exception.Message
                ExpiryDate = "N/A"
                Issuer     = "N/A"
            }
            $color = "Yellow"
        }

        # Visual terminal output
        Write-Host "Checking $ip... " -NoNewline
        Write-Host $certData.Status "($($certData.Reason))" -ForegroundColor $color
        $results += $certData
    }

    $results | Export-Csv -Path $outputFile -NoTypeInformation
    Write-Host "`nDone! Results in $outputFile" -ForegroundColor Cyan
}
else {
    Write-Host "Error: Could not find $inputFiles" -ForegroundColor Red
}
