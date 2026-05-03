<#
.SYNOPSIS
Checks whether one or more websites are reachable.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Url,

    [int]$TimeoutSeconds = 10,

    [string]$OutputPath
)

$results = foreach ($site in $Url) {
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $site -Method Head -TimeoutSec $TimeoutSeconds -UseBasicParsing
        $stopwatch.Stop()

        [PSCustomObject]@{
            Url                = $site
            StatusCode         = $response.StatusCode
            StatusDescription  = $response.StatusDescription
            ResponseTimeMs     = $stopwatch.ElapsedMilliseconds
            Result             = "Online"
            Timestamp          = Get-Date
        }
    }
    catch {
        [PSCustomObject]@{
            Url                = $site
            StatusCode         = "N/A"
            StatusDescription  = $_.Exception.Message
            ResponseTimeMs     = "N/A"
            Result             = "Offline or Error"
            Timestamp          = Get-Date
        }
    }
}

$results | Format-Table -AutoSize

if ($OutputPath) {
    $results | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Website report exported to $OutputPath"
}
