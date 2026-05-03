<#
.SYNOPSIS
Collects hardware inventory from all enabled computers in a specified Active Directory OU.

.DESCRIPTION
Queries Active Directory for computer objects in a target OU, then attempts to collect
hardware and operating system details from each computer using CIM.

This script is intended for authorized enterprise administration, lab use, and portfolio demonstration.
It does not modify Active Directory or endpoint configuration.

.REQUIREMENTS
ActiveDirectory PowerShell module
Domain joined workstation
Permission to read AD computer objects
WinRM or remote management access to target computers

.EXAMPLE
.\Get-ADComputerHardwareInventory.ps1 -SearchBase "OU=Workstations,OU=Computers,DC=example,DC=com" -OutputPath ".\sample-output\ad-computer-inventory.csv"

.EXAMPLE
.\Get-ADComputerHardwareInventory.ps1 -SearchBase "OU=Servers,DC=example,DC=com" -Credential (Get-Credential)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SearchBase,

    [string]$OutputPath = ".\ad-computer-hardware-inventory.csv",

    [System.Management.Automation.PSCredential]$Credential,

    [int]$TimeoutSeconds = 8
)

function Test-ComputerOnline {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    try {
        return Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop
    }
    catch {
        return $false
    }
}

function Get-RemoteCimData {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [System.Management.Automation.PSCredential]$Credential
    )

    try {
        $sessionOptions = New-CimSessionOption -Protocol Dcom

        if ($Credential) {
            $cimSession = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $sessionOptions -ErrorAction Stop
        }
        else {
            $cimSession = New-CimSession -ComputerName $ComputerName -SessionOption $sessionOptions -ErrorAction Stop
        }

        $computerSystem = Get-CimInstance -CimSession $cimSession -ClassName Win32_ComputerSystem -ErrorAction Stop
        $operatingSystem = Get-CimInstance -CimSession $cimSession -ClassName Win32_OperatingSystem -ErrorAction Stop
        $bios = Get-CimInstance -CimSession $cimSession -ClassName Win32_BIOS -ErrorAction Stop
        $processor = Get-CimInstance -CimSession $cimSession -ClassName Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $network = Get-CimInstance -CimSession $cimSession -ClassName Win32_NetworkAdapterConfiguration -ErrorAction Stop |
            Where-Object { $_.IPEnabled -eq $true } |
            Select-Object -First 1

        Remove-CimSession -CimSession $cimSession

        return [PSCustomObject]@{
            Manufacturer      = $computerSystem.Manufacturer
            Model             = $computerSystem.Model
            SerialNumber      = $bios.SerialNumber
            BIOSVersion       = ($bios.SMBIOSBIOSVersion)
            Processor         = $processor.Name
            MemoryGB          = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
            OSName            = $operatingSystem.Caption
            OSVersion         = $operatingSystem.Version
            LastBootTime      = $operatingSystem.LastBootUpTime
            LoggedOnUser      = $computerSystem.UserName
            IPAddress         = if ($network.IPAddress) { ($network.IPAddress -join ", ") } else { "Not Found" }
            CollectionStatus  = "Success"
            ErrorMessage      = ""
        }
    }
    catch {
        return [PSCustomObject]@{
            Manufacturer      = ""
            Model             = ""
            SerialNumber      = ""
            BIOSVersion       = ""
            Processor         = ""
            MemoryGB          = ""
            OSName            = ""
            OSVersion         = ""
            LastBootTime      = ""
            LoggedOnUser      = ""
            IPAddress         = ""
            CollectionStatus  = "Failed"
            ErrorMessage      = $_.Exception.Message
        }
    }
}

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    Write-Host "Querying Active Directory search base: $SearchBase"

    $computers = Get-ADComputer -SearchBase $SearchBase -Filter 'Enabled -eq $true' -Properties Name, DistinguishedName, OperatingSystem, LastLogonDate |
        Sort-Object Name

    if (-not $computers) {
        Write-Warning "No enabled computer objects were found in the specified OU."
        return
    }

    Write-Host "Found $($computers.Count) enabled computer objects."

    $results = foreach ($computer in $computers) {
        Write-Host "Checking $($computer.Name)..."

        $isOnline = Test-ComputerOnline -ComputerName $computer.Name

        if ($isOnline) {
            $hardware = Get-RemoteCimData -ComputerName $computer.Name -Credential $Credential
        }
        else {
            $hardware = [PSCustomObject]@{
                Manufacturer      = ""
                Model             = ""
                SerialNumber      = ""
                BIOSVersion       = ""
                Processor         = ""
                MemoryGB          = ""
                OSName            = $computer.OperatingSystem
                OSVersion         = ""
                LastBootTime      = ""
                LoggedOnUser      = ""
                IPAddress         = ""
                CollectionStatus  = "Offline"
                ErrorMessage      = "Host did not respond to ping."
            }
        }

        [PSCustomObject]@{
            ComputerName      = $computer.Name
            DistinguishedName = $computer.DistinguishedName
            LastLogonDate     = $computer.LastLogonDate
            Online            = $isOnline
            Manufacturer      = $hardware.Manufacturer
            Model             = $hardware.Model
            SerialNumber      = $hardware.SerialNumber
            BIOSVersion       = $hardware.BIOSVersion
            Processor         = $hardware.Processor
            MemoryGB          = $hardware.MemoryGB
            OSName            = $hardware.OSName
            OSVersion         = $hardware.OSVersion
            LastBootTime      = $hardware.LastBootTime
            LoggedOnUser      = $hardware.LoggedOnUser
            IPAddress         = $hardware.IPAddress
            CollectionStatus  = $hardware.CollectionStatus
            ErrorMessage      = $hardware.ErrorMessage
            Timestamp         = Get-Date
        }
    }

    $results | Format-Table ComputerName, Online, Manufacturer, Model, SerialNumber, OSName, MemoryGB, CollectionStatus -AutoSize

    $results | Export-Csv -Path $OutputPath -NoTypeInformation

    Write-Host "Inventory report exported to $OutputPath"
}
catch {
    Write-Error "Failed to collect AD computer hardware inventory. $($_.Exception.Message)"
}
