# 1. Setup Paths
$inputFiles = "C:\Temp\targets.txt"
$outputFile = "C:\Temp\CertResults.csv"

# 2. Force all possible TLS protocols for compatibility with older internal servers
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Tls13"

# Ensure the output directory exists
if (!(Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null }

$results = @()
$port = 443

if (Test-Path $inputFiles) {
    $targets = Get-Content $inputFiles
    Write-Host "Starting SSL Scan on $($targets.Count) targets...`n" -ForegroundColor Cyan

    foreach ($ip in $targets) {
        $ip = $ip.Trim()
        if ([string]::IsNullOrWhiteSpace($ip)) { continue }

        $status = "Success"
        $reason = "Valid"
        $color = "Green"
        $certData = $null

        try {
            # Attempt TCP Connection with a 2-second timeout
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connection = $tcpClient.BeginConnect($ip, $port, $null, $null)
            $wait = $connection.AsyncWaitHandle.WaitOne(2000, $false)

            if (-not $wait) { throw "Connection Timeout (Port 443 closed or blocked)" }
            $tcpClient.EndConnect($connection)

            # Establish SSL Stream
            # The { $true } block ignores trust errors so we can actually read the cert
            $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
            
            # The SSPI Fix: Using an empty string for the target host name bypasses 
            # the "Target Name Incorrect" error when connecting via IP.
            try {
                $sslStream.AuthenticateAsClient("")
            } catch {
                # Fallback to IP if the server requires a string
                $sslStream.AuthenticateAsClient($ip)
            }

            $cert = $sslStream.RemoteCertificate
            $tcpClient.Close()

            if ($cert) {
                $expiryDate = [DateTime]::Parse($cert.GetExpirationDateString())
                $issuer = $cert.Issuer
                $subject = $cert.Subject

                # Logic: Check for Self-Signed (Subject matches Issuer)
                if ($subject -eq $issuer) {
                    $status = "Fail"
                    $reason = "Self-Signed"
                    $color = "Red"
                }
                # Logic: Check for Expiration
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
            # Handle SSPI failures, Timeouts, and Refused connections
            $errorMessage = $_.Exception.Message
            if ($_.Exception.InnerException) { $errorMessage += " ($($_.Exception.InnerException.Message))" }
            
            $certData = [PSCustomObject]@{
                IPAddress  = $ip
                Status     = "Fail"
                Reason     = $errorMessage
                ExpiryDate = "N/A"
                Issuer     = "N/A"
            }
            $color = "Yellow"
        }

        # Terminal Visuals
        Write-Host "Checking $ip... " -NoNewline
        Write-Host $certData.Status "($($certData.Reason))" -ForegroundColor $color
        
        $results += $certData
    }

    # 3. Export to CSV (Note: CSV does not store colors)
    $results | Export-Csv -Path $outputFile -NoTypeInformation
    Write-Host "`nScan Complete. Report saved to: $outputFile" -ForegroundColor Cyan
}
else {
    Write-Host "Error: Could not find $inputFiles" -ForegroundColor Red
}
