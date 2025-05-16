function Test-ServerSSLSupport{
    [CmdletBinding()]
    param(
        [string][Parameter(Mandatory = $true, ValueFromPipeline = $true, Position=0)][ValidateNotNullOrEmpty()]$hostname,
        [UInt16][Parameter(Mandatory = $false, Position=1)]$port = 443
    )
    process {
        Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tTesting TCP connection on port $($port) to host $($hostname)" -ForegroundColor Cyan   
        if(([uri]($hostname)).host){
            $hostname1 = ([uri]($hostname)).host
        }
        else{
            $hostname1 = $hostname
        }
        try{
            $ips1 = @(([ipaddress]$hostname1).IPAddressToString)
        }
        catch{
            try{
                $ips1 = @(Resolve-DnsName $hostname1 -ErrorAction Stop | Where-Object{
                    $_.type -match "^(A|AAAA)$"
                }).ipaddress
            }
            catch{
                $ips1 = $null
            }
        }
        if($ips1){
            $result1 = @( foreach($ip1 in $ips1){
                $test1 = Test-netConnection $ip1 -Port $port
                if($test1.TcpTestSucceeded){
                    $protocols1 = @([enum]::GetValues([System.Security.Authentication.SslProtocols]))
                    foreach($protocol in $protocols1){
                        $TcpClient = New-Object Net.Sockets.TcpClient
                        try{
                            $TcpClient.Connect($ip1, $port)
                        }
                        catch{
                        }
                        if($TcpClient.connected){
                            $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream(), $true, ([System.Net.Security.RemoteCertificateValidationCallback]{ $true })
                            $SslStream.ReadTimeout = 15000
                            $SslStream.WriteTimeout = 15000
                            try {
                                $SslStream.AuthenticateAsClient($ip1.IPAddress,$null,$protocol,$false)
                            }
                            catch{
                            }
                            $SslStream | Select-Object @{l="hostname";e={
                                $hostname
                            }},@{l="port";e={
                                $port
                            }},@{l="ipaddress";e={
                                $ip1
                            }},@{l="tryprotocol";e={
                                $protocol
                            }},*
                        }
                        else{
                            Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed TCP connection to port $($port) on host:`t$($ip1)" -ForegroundColor Yellow        
                        }
                        $TcpClient.Dispose()
                        $SslStream.Dispose()
                    }
                }
                else{
                    Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed test TCP connection to port $($port) on host: $($ip1) using command:`t'$('$TcpClient.Connect($ip1, $port)')'" -ForegroundColor Yellow
                }
            })
        }
        else{
            Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed to get IPv4 address for host:`t$($hostname)" -ForegroundColor Yellow
        }
        return $result1
    }  
}
Test-ServerSSLSupport -hostname *webserver* -port 443
