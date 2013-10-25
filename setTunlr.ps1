# Powershell script to toggle tunlr DNS.  Needs to be run as administrator.
# zdv 2013-04-13

# Prompt for enable/disable action
Param ([string]$enable = $( Read-Host "[E]nable or [d]isable tunlr?" ))

# Set the DNS servers for the supplied adapter
Function SetDnsForAdapter ($adapter, $servers)
{
    $retVal = $adapter.SetDNSServerSearchOrder($servers).ReturnValue
    
    if ($retVal -ne 0)
    {
        Throw "Could not set DNS on $($adapter.Description). Code: ${retVal}"
    }
}

# Set system DNS based on enabling/disabling tunlr.
Function SetDns ($enable)
{
    $adapters = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"

    foreach ($adapter in $adapters)
    {
        $serverList = $null
        if ($enable)
        {
            $serverList = "69.197.169.9","192.95.16.109"
        }
        SetDnsForAdapter $adapter $serverList
    }
}

# Script body
Try
{
    SetDns ($enable -ieq "e")
    ipconfig /flushdns | Out-Null
    Write-Output "Success!"
    Start-Process -FilePath "http://tunlr.net/status/"
}
Catch [Exception]
{
    Write-Output "ERROR: $_"
}
Finally
{
    Write-Host -NoNewline "Press any key to exit..."
    $unused = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}