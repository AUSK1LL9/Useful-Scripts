# Define input and output paths
$inputFile = "C:\temp\machinelist.txt"
$outputFile = "C:\temp\NetworkResults.csv"
if (-not (Test-Path $inputFile)) {
    Write-Error "Input file not found at $inputFile"
    return
}
$results = foreach ($target in Get-Content $inputFile) {
    $target = $target.Trim()
    if ([string]::IsNullOrWhiteSpace($target)) { continue }

    Write-Host "Processing: $target" -ForegroundColor Cyan
    $forwardPass = try {
        $null = Resolve-DnsName -Name $target -ErrorAction Stop
        "Pass"
    } catch {
        "Fail"
    }
    $reversePass = try {
        $ip = [System.Net.Dns]::GetHostAddresses($target)[0].IPAddressToString
        $null = Resolve-DnsName -Name $ip -ErrorAction Stop
        "Pass"
    } catch {
        "Fail"
    }
    $pingPass = if (Test-Connection -ComputerName $target -Count 1 -Quiet) {
        "Pass"
    } else {
        "Fail"
    }
    [PSCustomObject]@{
        Target         = $target
        ForwardLookup  = $forwardPass
        ReverseLookup  = $reversePass
        PingResponse   = $pingPass
    }
}
$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Scan complete. Results saved to $outputFile" -ForegroundColor Green
