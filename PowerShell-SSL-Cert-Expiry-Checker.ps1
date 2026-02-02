$inputFiles = "C:\Temp\targets.txt"
$outputFile = "C:\Temp\CertResults.csv"
$results = @()

# Define the port (usually 443 for SSL)
$port = 443

foreach ($ip in Get-Content $inputFiles) {
    $ip = $ip.Trim()
    if ([string]::IsNullOrWhiteSpace($ip)) { continue }

    $status = "Success"
    $reason = "Valid"
    $color = "Green"

    try {
        # Establish connection and grab the certificate
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($ip, $port)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($ip)
        $cert = $sslStream.RemoteCertificate
        $tcpClient.Close()

        if ($cert) {
            $expiryDate = [DateTime]::Parse($cert.GetExpirationDateString())
            $issuer = $cert.Issuer
            $subject = $cert.Subject

            # Check if Self-Signed (Subject matches Issuer)
            if ($subject -eq $issuer) {
                $status = "Fail"
                $reason = "Self-Signed"
                $color = "Red"
            }
            # Check if Expired
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
            Reason     = "Connection Failed"
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

# Export to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "`nResults exported to $outputFile" -ForegroundColor Cyan
