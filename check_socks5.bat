@echo off
title SOCKS5 Real Working Checker
color 0A
cd /d "%~dp0"

if not exist "IPs.txt" (
    echo.
    echo  [ERROR] IPs.txt not found!
    timeout /t 4 >nul
    exit
)

echo.
echo  ========================================
echo     SOCKS5 Real Working Checker
echo  ========================================
echo.
echo  Method       : Full SOCKS5 + Connect to 1.1.1.1
echo  Threads      : 100
echo  Timeout      : 10 seconds
echo  Starting... Please wait.
echo.

(
echo $ErrorActionPreference = "SilentlyContinue"
echo $inputFile = "IPs.txt"
echo $workingFile = "working.txt"
echo $logFile = "results_log.txt"
echo $maxThreads = 100
echo $timeout = 10
echo.
echo if ^(Test-Path $workingFile^) { Remove-Item $workingFile -Force }
echo if ^(Test-Path $logFile^) { Remove-Item $logFile -Force }
echo.
echo $proxies = Get-Content $inputFile ^| Where-Object { $_.Trim^(^) -ne "" }
echo $total = $proxies.Count
echo Write-Host "Total proxies: $total" -ForegroundColor Cyan
echo Write-Host "Testing with full SOCKS5 CONNECT to 1.1.1.1:80" -ForegroundColor Cyan
echo Write-Host ""
echo.
echo $scriptBlock = {
echo     param^($proxyLine, $timeout^)
echo     $result = "DEAD"
echo     try {
echo         $parts = $proxyLine.Trim^(^).Split^(":"^)
echo         if ^($parts.Count -lt 2^) { return "$proxyLine^|DEAD" }
echo         $ip = $parts[0]
echo         $port = [int]$parts[1]
echo.
echo         $client = New-Object System.Net.Sockets.TcpClient
echo         $iar = $client.BeginConnect^($ip, $port, $null, $null^)
echo         $success = $iar.AsyncWaitHandle.WaitOne^($timeout * 1000, $false^)
echo         if ^(-not $success -or -not $client.Connected^) {
echo             $client.Close^(^)
echo             return "$proxyLine^|DEAD"
echo         }
echo.
echo         $stream = $client.GetStream^(^)
echo         $stream.ReadTimeout = $timeout * 1000
echo         $stream.WriteTimeout = $timeout * 1000
echo.
echo         # SOCKS5 Greeting
echo         $stream.Write^([byte[]]^(0x05, 0x01, 0x00^), 0, 3^)
echo         $response = New-Object byte[] 2
echo         $read = $stream.Read^($response, 0, 2^)
echo         if ^($read -lt 2 -or $response[0] -ne 0x05 -or $response[1] -ne 0x00^) {
echo             $client.Close^(^)
echo             return "$proxyLine^|AUTH"
echo         }
echo.
echo         # CONNECT request to 1.1.1.1:80
echo         $targetIP = [System.Net.IPAddress]::Parse^("1.1.1.1"^)
echo         $request = New-Object byte[] 10
echo         $request[0] = 0x05   # VER
echo         $request[1] = 0x01   # CMD = CONNECT
echo         $request[2] = 0x00   # RSV
echo         $request[3] = 0x01   # ATYP = IPv4
echo         $targetIP.GetAddressBytes^(^).CopyTo^($request, 4^)
echo         $request[8] = 0x00   # Port high
echo         $request[9] = 0x50   # Port 80
echo.
echo         $stream.Write^($request, 0, 10^)
echo         $reply = New-Object byte[] 10
echo         $read = $stream.Read^($reply, 0, 10^)
echo.
echo         if ^($read -ge 2 -and $reply[0] -eq 0x05 -and $reply[1] -eq 0x00^) {
echo             $result = "LIVE"
echo         } else {
echo             $result = "FAIL"
echo         }
echo         $client.Close^(^)
echo     } catch {
echo         $result = "DEAD"
echo     }
echo     return "$proxyLine^|$result"
echo }
echo.
echo $pool = [runspacefactory]::CreateRunspacePool^(1, $maxThreads^)
echo $pool.Open^(^)
echo $runspaces = New-Object System.Collections.ArrayList
echo.
echo foreach ^($p in $proxies^) {
echo     $ps = [powershell]::Create^(^)
echo     $ps.AddScript^($scriptBlock^) ^| Out-Null
echo     $ps.AddArgument^($p^) ^| Out-Null
echo     $ps.AddArgument^($timeout^) ^| Out-Null
echo     $ps.RunspacePool = $pool
echo     [void]$runspaces.Add^([PSCustomObject]@{ Pipe = $ps; Status = $ps.BeginInvoke^(^) }^)
echo }
echo.
echo $live = 0
echo $done = 0
echo.
echo while ^($done -lt $total^) {
echo     foreach ^($rs in $runspaces.ToArray^(^)^) {
echo         if ^($rs.Status.IsCompleted^) {
echo             $output = $rs.Pipe.EndInvoke^($rs.Status^)
echo             $rs.Pipe.Dispose^(^)
echo             $runspaces.Remove^($rs^)
echo             $done++
echo.
echo             if ^($output^) {
echo                 $split = $output -split "\|"
echo                 $line = $split[0]
echo                 $status = $split[1]
echo.
echo                 if ^($status -eq "LIVE"^) {
echo                     Write-Host "[LIVE] $line" -ForegroundColor Green
echo                     Add-Content -Path $workingFile -Value $line
echo                     Add-Content -Path $logFile -Value "$line - LIVE"
echo                     $live++
echo                 }
echo                 elseif ^($status -eq "AUTH"^) {
echo                     Write-Host "[AUTH] $line" -ForegroundColor Yellow
echo                     Add-Content -Path $logFile -Value "$line - AUTH REQUIRED"
echo                 }
echo                 else {
echo                     Write-Host "[DEAD] $line" -ForegroundColor DarkGray
echo                     Add-Content -Path $logFile -Value "$line - DEAD"
echo                 }
echo             }
echo.
echo             if ^($done %% 50 -eq 0 -or $done -eq $total^) {
echo                 Write-Host "----- Progress: $done / $total  ^|  Live: $live -----" -ForegroundColor Cyan
echo             }
echo         }
echo     }
echo     Start-Sleep -Milliseconds 100
echo }
echo.
echo $pool.Close^(^)
echo $pool.Dispose^(^)
echo.
echo Write-Host ""
echo Write-Host "========================================" -ForegroundColor Green
echo Write-Host "  FINISHED" -ForegroundColor Green
echo Write-Host "========================================" -ForegroundColor Green
echo Write-Host "Total Checked : $done"
echo Write-Host "Real Working  : $live" -ForegroundColor Green
echo Write-Host ""
echo Write-Host "Only real working proxies saved in: working.txt"
echo Write-Host ""
echo Write-Host "Window closes in 10 seconds..."
echo Start-Sleep -Seconds 10
) > "%TEMP%\real_socks_check.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\real_socks_check.ps1"
del "%TEMP%\real_socks_check.ps1" >nul 2>&1
exit