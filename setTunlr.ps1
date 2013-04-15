Param ([string]$enable = $( Read-Host "[E]nable or [d]isable tunlr?" ))

Function SetDnsForAdapter ($adapter, $servers)
{
    $retVal = $adapter.SetDNSServerSearchOrder($servers).ReturnValue
    
    if ($retVal -ne 0)
    {
        Throw "Could not set DNS on $($adapter.Description). Code: ${retVal}"
    }
}

Function SetDns ($enable)
{
    $adapters = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"

    foreach ($adapter in $adapters)
    {
        $serverList = $null
        if ($enable)
        {
            $serverList = "192.95.16.109","142.54.177.158"
        }
        SetDnsForAdapter $adapter $serverList
    }
}

Try
{
    SetDns ($enable -ieq "e")
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