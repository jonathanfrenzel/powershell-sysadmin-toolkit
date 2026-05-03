<#
.SYNOPSIS
Retrieves recent failed Windows logon events.

.NOTES
Run as Administrator for best results.
Event ID 4625 is a failed logon.
#>

[CmdletBinding()]
param(
    [int]$HoursBack = 24,
    [int]$MaxEvents = 25,
    [string]$OutputPath
)

try {
    $startTime = (Get-Date).AddHours(-$HoursBack)

    $events = Get-WinEvent -FilterHashtable @{
        LogName   = "Security"
        Id        = 4625
        StartTime = $startTime
    } -MaxEvents $MaxEvents -ErrorAction Stop

    $results = $events | ForEach-Object {
        $xml = [xml]$_.ToXml()
        $data = @{}
        foreach ($item in $xml.Event.EventData.Data) {
            $data[$item.Name] = $item.'#text'
        }

        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            TimeCreated  = $_.TimeCreated
            TargetUser   = $data["TargetUserName"]
            Workstation  = $data["WorkstationName"]
            IpAddress    = $data["IpAddress"]
            LogonType    = $data["LogonType"]
            Status       = $data["Status"]
        }
    }

    $results | Format-Table -AutoSize

    if ($OutputPath) {
        $results | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Failed logon report exported to $OutputPath"
    }
}
catch {
    Write-Warning "Could not retrieve failed logon events. Try running PowerShell as Administrator. $($_.Exception.Message)"
}
