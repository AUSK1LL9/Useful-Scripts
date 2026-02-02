# Define input and output paths
$inputFile = "C:\temp\targets.txt"
$outputFile = "C:\temp\NetworkResults.csv"
$MaxThreads = 20 

if (-not (Test-Path $inputFile)) { Write-Error "Input file not found"; return }
$targets = Get-Content $inputFile | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

Write-Host "Starting Multi-Threaded scan on $($targets.Count) targets..." -ForegroundColor Yellow

$ScriptBlock = {
    param($target)
    
    # Fast Port Check Function
    $TestPort = {
        param($IP, $Port)
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($IP, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(1000, $false)
        if ($wait -and $tcpClient.Connected) {
            $tcpClient.Close(); return "Yes"
        } else {
            $tcpClient.Close(); return "No"
        }
    }

    # 1. Forward Lookup (Verify it exists)
    $forward = try { 
        $null = Resolve-DnsName -Name $target -ErrorAction Stop
        "Pass" 
    } catch { "Fail" }

    # 2. Reverse Lookup (Get the FQDN)
    $dnsName = "N/A"
    $reverse = try {
        # We query for PTR specifically to get the hostname from an IP
        $rev = Resolve-DnsName -Name $target -Type PTR -ErrorAction Stop
        # Select the hostname; handle multiple results if they exist
        $dnsName = ($rev | Select-Object -ExpandProperty NameHost -First 1)
        "Pass"
    } catch {
        # Fallback: some DNS setups return the name in the 'Name' field instead
        try {
            $rev = Resolve-DnsName -Name $target -ErrorAction Stop
            $dnsName = $rev.Name
            "Pass"
        } catch { "Fail" }
    }

    # 3. Ping
    $ping = if (Test-Connection -ComputerName $target -Count 1 -Quiet) { "Pass" } else { "Fail" }

    return [PSCustomObject]@{
        Target         = $target
        DNS_Hostname   = $dnsName
        ForwardLookup  = $forward
        ReverseLookup  = $reverse
        PingResponse   = $ping
        SSH_22         = &$TestPort $target 22
        HTTPS_443      = &$TestPort $target 443
        Web_9443       = &$TestPort $target 9443
        RDP_3389       = &$TestPort $target 3389
    }
}

# --- Runspace Pool Management ---
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()
$Jobs = New-Object System.Collections.Generic.List[object]

foreach ($t in $targets) {
    $PowerShell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($t)
    $PowerShell.RunspacePool = $RunspacePool
    $Jobs.Add(@{ Instance = $PowerShell; Handle = $PowerShell.BeginInvoke() })
}

# Collect results
$results = foreach ($job in $Jobs) {
    $job.Instance.EndInvoke($job.Handle)
    $job.Instance.Dispose()
}
$RunspacePool.Close()

# Sort by Target and Export
$results | Sort-Object Target | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Scan complete. Results saved to $outputFile" -ForegroundColor Green
