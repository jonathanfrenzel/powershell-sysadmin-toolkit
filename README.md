# PowerShell Systems Administration Toolkit

A practical PowerShell toolkit for Windows systems administration, troubleshooting, monitoring, reporting, and repeatable IT support workflows.

## Project Purpose

This project demonstrates how PowerShell can be used to automate common systems administration tasks and standardize troubleshooting across Windows environments.

The toolkit is designed for IT support, systems administration, cloud operations, and infrastructure troubleshooting scenarios.

## Skills Demonstrated

PowerShell scripting  
Windows administration  
System health monitoring  
Service validation  
Disk utilization reporting  
Event log review  
Website availability testing  
CSV reporting  
Technical documentation  
Repeatable troubleshooting workflows  

## Scripts Included

| Script | Purpose |
| --- | --- |
| `Get-ADComputerHardwareInventory.ps1` | Queries Active Directory for enabled computers in a target OU and collects hardware inventory using CIM |
| `Get-SystemHealth.ps1` | Generates a local system health report with OS, uptime, CPU, memory, and timestamp |
| `Check-DiskSpace.ps1` | Checks local disk usage and flags drives below a free space threshold |
| `Check-ServiceStatus.ps1` | Checks whether important Windows services are running |
| `Check-WebsiteStatus.ps1` | Tests website availability and response time |
| `Get-FailedLogons.ps1` | Pulls recent failed Windows logon events from the Security event log |
| `Generate-InventoryReport.ps1` | Exports basic system inventory to CSV |
| `Mock-UserOnboarding.ps1` | Simulates a safe user onboarding checklist without creating real accounts |

## Repository Structure

```text
powershell-sysadmin-toolkit/
├── scripts/
│   ├── Get-ADComputerHardwareInventory.ps1
│   ├── Get-SystemHealth.ps1
│   ├── Check-DiskSpace.ps1
│   ├── Check-ServiceStatus.ps1
│   ├── Check-WebsiteStatus.ps1
│   ├── Get-FailedLogons.ps1
│   ├── Generate-InventoryReport.ps1
│   └── Mock-UserOnboarding.ps1
├── examples/
├── sample-output/
├── README.md
└── .gitignore
