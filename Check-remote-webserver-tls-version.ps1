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
                            # Connection failed at TCP level for some reason, even if Test-NetConnection succeeded.
                            # This can happen if the port is open but the service isn't ready or immediately closes.
                        }
                        if($TcpClient.connected){
                            $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream(), $true, ([System.Net.Security.RemoteCertificateValidationCallback]{ $true })
                            $SslStream.ReadTimeout = 15000
                            $SslStream.WriteTimeout = 15000
                            try {
                                $SslStream.AuthenticateAsClient($ip1.IPAddress,$null,$protocol,$false)
                            }
                            catch{
                                # SSL Handshake failed for this protocol.
                            }
                            
                            # Select only the critical information
                            $SslStream | Select-Object @{l="hostname";e={ $hostname }},
                                @{l="port";e={ $port }},
                                @{l="ipaddress";e={ $ip1.IPAddressToString }},
                                @{l="tryprotocol";e={ $protocol.ToString() }},
                                @{l="SslHandshakeSuccessful";e={ $SslStream.IsAuthenticated }},
                                @{l="NegotiatedSslProtocol";e={ if($SslStream.IsAuthenticated){ $SslStream.SslProtocol.ToString() } else { $null } }},
                                @{l="CipherAlgorithm";e={ if($SslStream.IsAuthenticated){ $SslStream.CipherAlgorithm.ToString() } else { $null } }},
                                @{l="RemoteCertificateSubject";e={ if($SslStream.RemoteCertificate){ $SslStream.RemoteCertificate.Subject } else { $null } }},
                                @{l="RemoteCertificateIssuer";e={ if($SslStream.RemoteCertificate){ $SslStream.RemoteCertificate.Issuer } else { $null } }},
                                @{l="RemoteCertificateNotBefore";e={ if($SslStream.RemoteCertificate){ $SslStream.RemoteCertificate.NotBefore } else { $null } }},
                                @{l="RemoteCertificateNotAfter";e={ if($SslStream.RemoteCertificate){ $SslStream.RemoteCertificate.NotAfter } else { $null } }}
                        }
                        else{
                            Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed TCP connection to port $($port) on host:`t$($ip1) for protocol attempt $($protocol)" -ForegroundColor Yellow        
                        }
                        # Dispose of resources
                        if($SslStream){ $SslStream.Dispose() }
                        if($TcpClient){ $TcpClient.Dispose() }
                    }
                }
                else{
                    Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed test TCP connection to port $($port) on host: $($ip1)" -ForegroundColor Yellow
                }
            })
        }
        else{
            Write-Host "$(get-date -Format "yyyy-MM-dd HH:mm")`tFailed to get IPv4 address for host:`t$($hostname)" -ForegroundColor Yellow
        }
        return $result1
    }    
}

# Example usage (replace *webserver* with your actual hostname)
Test-ServerSSLSupport -hostname "*server*" -port 443
