# Define input and output paths
$inputFile = "C:\temp\machinelist.txt"
$outputFile = "C:\temp\NetworkResults.csv"

# --- Functions ---
function Check-Port {
    param($pcTarget, $pcPort)
    # Corrected syntax: Wrapped the command in parentheses properly
    $check = Test-NetConnection -ComputerName $pcTarget -Port $pcPort -WarningAction SilentlyContinue
    if ($check.TcpTestSucceeded) {
        return "Yes"
    } else {
        return "No"
    }
}

# --- Main Logic ---

# Check if input file exists
if (-not (Test-Path $inputFile)) {
    Write-Error "Input file not found at $inputFile"
    return
}

$results = foreach ($target in Get-Content $inputFile) {
    $target = $target.Trim()
    if ([string]::IsNullOrWhiteSpace($target)) { continue }

    Write-Host "Processing: $target" -ForegroundColor Cyan

    # 1. Forward Lookup & FQDN Retrieval
    $fqdnResult = "N/A"
    $forwardPass = try {
        $dnsMatch = Resolve-DnsName -Name $target -ErrorAction Stop | Select-Object -First 1
        $fqdnResult = $dnsMatch.Name
        "Pass"
    } catch {
        "Fail"
    }

    # 2. Reverse Lookup Check
    $reversePass = try {
        $ip = [System.Net.Dns]::GetHostAddresses($target)[0].IPAddressToString
        $null = Resolve-DnsName -Name $ip -ErrorAction Stop
        "Pass"
    } catch {
        "Fail"
    }

    # 3. Ping Check
    $pingPass = if (Test-Connection -ComputerName $target -Count 1 -Quiet) { "Pass" } else { "Fail" }

    # 4. Port Checks (using the function defined above)
    [PSCustomObject]@{
        Target         = $target
        Resolved_FQDN  = $fqdnResult
        ForwardLookup  = $forwardPass
        ReverseLookup  = $reversePass
        PingResponse   = $pingPass
        SSH_22         = Check-Port -pcTarget $target -pcPort 22
        HTTPS_443      = Check-Port -pcTarget $target -pcPort 443
        Web_9443       = Check-Port -pcTarget $target -pcPort 9443
        RDP_3389       = Check-Port -pcTarget $target -pcPort 3389
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Scan complete. Results saved to $outputFile" -ForegroundColor Green
