# Define input and output paths
$inputFile = "C:\temp\targets.txt"
$outputFile = "C:\temp\NetworkResults.csv"

# --- Functions ---
function Check-Port {
    param($pcTarget, $pcPort)
    # Using a shorter timeout (1000ms) can speed up scans on dead IPs
    $check = Test-NetConnection -ComputerName $pcTarget -Port $pcPort -WarningAction SilentlyContinue
    if ($check.TcpTestSucceeded) { return "Yes" } else { return "No" }
}

# --- Main Logic ---
if (-not (Test-Path $inputFile)) {
    Write-Error "Input file not found at $inputFile"
    return
}

$results = foreach ($target in Get-Content $inputFile) {
    $target = $target.Trim()
    if ([string]::IsNullOrWhiteSpace($target)) { continue }

    Write-Host "Processing: $target" -ForegroundColor Cyan

    $ipAddress = $null
    $fqdnResult = "N/A"
    
    # 1. Forward Lookup / IP Validation
    # If input is an IP, this validates it exists; if Hostname, it finds the IP.
    $forwardPass = try {
        $dnsMatch = Resolve-DnsName -Name $target -ErrorAction Stop | Select-Object -First 1
        $ipAddress = $dnsMatch.IPAddress
        $fqdnResult = $dnsMatch.Name
        "Pass"
    } catch {
        "Fail"
    }

    # 2. Reverse Lookup
    # We use the IP address found above. If the input was already an IP, it uses that string.
    $reversePass = try {
        $lookupTarget = if ($ipAddress) { $ipAddress } else { $target }
        $null = Resolve-DnsName -Name $lookupTarget -ErrorAction Stop
        "Pass"
    } catch {
        "Fail"
    }

    # 3. Ping Check
    $pingPass = if (Test-Connection -ComputerName $target -Count 1 -Quiet) { "Pass" } else { "Fail" }

    # 4. Port Checks & Object Creation
    [PSCustomObject]@{
        Target         = $target
        Resolved_IP    = if($ipAddress) { $ipAddress } else { "Unknown" }
        Resolved_FQDN  = $fqdnResult
        ForwardLookup  = $forwardPass
        ReverseLookup  = $reversePass
        PingResponse   = $pingPass
        SSH_22         = Check-Port $target 22
        HTTPS_443      = Check-Port $target 443
        Web_9443       = Check-Port $target 9443
        RDP_3389       = Check-Port $target 3389
    }
}

$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Optimized scan complete. Results: $outputFile" -ForegroundColor Green
