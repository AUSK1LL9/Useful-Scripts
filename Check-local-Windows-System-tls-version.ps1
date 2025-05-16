#Requires -RunAsAdministrator
# Get system information
$hostname = hostname
$fqdn = ([System.Net.Dns]::GetHostEntry($hostname)).HostName
$ipAddress = (Get-NetIPConfiguration | Where-Object {$_.IPv4Address} | Select-Object -First 1).IPv4Address.IPAddress
$osInfo = Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version

# Get logged in user information
$loggedInUser = $env:USERNAME
$upn = $loggedInUser # Default to username if UPN retrieval fails

# Attempt to get UPN if running with elevated privileges
if ((([System.Security.Principal.WindowsPrincipal] ([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
    try {
        $principal = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $upnResult = (New-Object System.DirectoryServices.DirectorySearcher("(&(objectClass=user)(objectSid=$($principal.User.Value)))")).FindOne()
        if ($upnResult -and $upnResult.Properties.userprincipalname) {
            $upn = $upnResult.Properties.userprincipalname
        } else {
            Write-Warning "Could not retrieve full UPN. Ensure the machine is domain-joined and the script has necessary permissions."
        }
    }
    catch {
        Write-Warning "Error retrieving UPN. Ensure the Active Directory module is available and the script is run with appropriate permissions."
    }
} else {
    Write-Warning "Run the script as Administrator to attempt retrieval of the User Principal Name (UPN)."
}

# Get enabled TLS protocols
$enabledTLS = @()
$securityProtocol = [Net.ServicePointManager]::SecurityProtocol
if ($securityProtocol -band [Net.SecurityProtocolType]::Tls10) {
    $enabledTLS += "TLS 1.0"
}
if ($securityProtocol -band [Net.SecurityProtocolType]::Tls11) {
    $enabledTLS += "TLS 1.1"
}
if ($securityProtocol -band [Net.SecurityProtocolType]::Tls12) {
    $enabledTLS += "TLS 1.2"
}
if ($securityProtocol -band [Net.SecurityProtocolType]::Tls13) {
    $enabledTLS += "TLS 1.3"
}

# Function to get allowed ciphers for a specific TLS version (requires .NET 4.6+)
function Get-AllowedCiphers {
    param(
        [string]$tlsVersion
    )
    try {
        if ([System.Enum]::TryParse([System.Security.Authentication.SslProtocols], $tlsVersion, $true, [ref]$protocol)) {
            $tlsCipherSuites = [System.Net.Security.CipherSuitesPolicy]::SupportedCipherSuites($protocol)
            if ($tlsCipherSuites) {
                return $tlsCipherSuites.Name -join ', '
            } else {
                return "No specific ciphers configured (system default)."
            }
        } else {
            return "Invalid TLS version specified."
        }
    } catch {
        return "Error retrieving cipher information (requires .NET 4.6+)."
    }
}

# Format and display the results
Write-Host "System Information:"
Write-Host "  Hostname: $($hostname)"
Write-Host "  FQDN: $($fqdn)"
Write-Host "  IP Address: $($ipAddress)"
Write-Host "  OS: $($osInfo.Caption) $($osInfo.Version)"
Write-Host "  Logged In User: $($loggedInUser)"
Write-Host "  User Principal Name (UPN): $($upn)"
Write-Host ""
Write-Host "Enabled TLS Protocols and Allowed Ciphers:"
if ($enabledTLS.Count -gt 0) {
    foreach ($tls in $enabledTLS) {
        Write-Host "  $($tls):"
        $ciphers = Get-AllowedCiphers -tlsVersion $tls
        Write-Host "    Allowed Ciphers: $($ciphers)"
    }
} else {
    Write-Host "  No TLS protocols explicitly enabled (system default)."
}
