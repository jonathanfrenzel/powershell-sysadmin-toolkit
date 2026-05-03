<#
.SYNOPSIS
Generates a basic local system inventory report.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\inventory-report.csv"
)

try {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

    $report = [PSCustomObject]@{
        ComputerName      = $env:COMPUTERNAME
        Manufacturer      = $computer.Manufacturer
        Model             = $computer.Model
        SerialNumber      = $bios.SerialNumber
        OSName            = $os.Caption
        OSVersion         = $os.Version
        Processor         = $processor.Name
        MemoryGB          = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
        DomainOrWorkgroup = if ($computer.PartOfDomain) { $computer.Domain } else { $computer.Workgroup }
        CurrentUser       = $computer.UserName
        Timestamp         = Get-Date
    }

    $report | Format-List
    $report | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Inventory report exported to $OutputPath"
}
catch {
    Write-Error "Failed to generate inventory report. $($_.Exception.Message)"
}
