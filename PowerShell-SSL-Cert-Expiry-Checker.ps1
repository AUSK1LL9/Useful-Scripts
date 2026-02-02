# 1. Setup Paths
$inputFiles = "C:\Temp\targets.txt"
$outputFile = "C:\Temp\CertResults.csv"

# Force TLS 1.2 and 1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# This bypasses all SSL validation errors (Self-signed, Name mismatch, etc.)
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$results = @()

if (Test-Path $inputFiles) {
    $targets = Get-Content $inputFiles
    Write-Host "Starting Resilient Scan on $($targets.Count) targets...`n" -ForegroundColor Cyan

    foreach ($ip in $targets) {
        $ip = $ip.Trim()
        if ([string]::IsNullOrWhiteSpace($ip)) { continue }

        $status = "Success"
        $reason = "Valid"
        $color = "Green"
        $certData = $null

        try {
            # Create a web request to the IP
            $url = "https://$ip"
            $request = [System.Net.HttpWebRequest]::Create($url)
            $request.Timeout = 3000 # 3 second timeout
            $request.AllowAutoRedirect = $false
            
            # This triggers the handshake
            $response = $request.GetResponse()
            $response.Close()
            
            # Retrieve the certificate from the service point
            $cert = $request.ServicePoint.Certificate
        }
        catch {
            # Even if the request "fails" (like a 403 or 401), the cert is often still captured
            $cert = $request.ServicePoint.Certificate
            
            if (-not $cert) {
                $status = "Fail"
                $reason = $_.Exception.Message
                $color = "Yellow"
            }
        }

        if ($cert) {
            # Cast to X509Certificate2 to get detailed properties
            $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
            
            $expiryDate = $cert2.NotAfter
            $issuer = $cert2.Issuer
            $subject = $cert2.Subject

            # Logic: Check for Self-Signed
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
        else {
            # No cert found at all
            $certData = [PSCustomObject]@{
                IPAddress  = $ip
                Status     = "Fail"
                Reason     = "Could not retrieve certificate"
                ExpiryDate = "N/A"
                Issuer     = "N/A"
            }
        }

        # Terminal Output
        Write-Host "Checking $ip... " -NoNewline
        Write-Host $certData.Status "($($certData.Reason))" -ForegroundColor $color
        $results += $certData
    }

    $results | Export-Csv -Path $outputFile -NoTypeInformation
    Write-Host "`nScan Complete. Report saved to: $outputFile" -ForegroundColor Cyan
}
else {
    Write-Host "Error: $inputFiles not found." -ForegroundColor Red
}
