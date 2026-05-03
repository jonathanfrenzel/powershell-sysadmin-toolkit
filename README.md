# PowerShell Systems Administration Toolkit

A Windows systems administration toolkit for repeatable troubleshooting, health checks, service validation, disk utilization reviews, website availability checks, and basic reporting.

## Purpose

This project demonstrates practical PowerShell automation for IT support, systems administration, cloud operations, and infrastructure troubleshooting.

## Scripts

| Script | Purpose |
| --- | --- |
| Get-SystemHealth.ps1 | Generates a local system health report |
| Check-DiskSpace.ps1 | Checks disk usage and flags low free space |
| Check-ServiceStatus.ps1 | Checks important Windows services |
| Check-WebsiteStatus.ps1 | Tests website availability and response time |
| Get-FailedLogons.ps1 | Pulls recent failed logon events |
| Generate-InventoryReport.ps1 | Exports basic system inventory to CSV |
| Mock-UserOnboarding.ps1 | Simulates a user onboarding checklist |

## Quick Start

Open PowerShell as Administrator when needed.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Run a script:

```powershell
.\scripts\Get-SystemHealth.ps1
```

Export results:

```powershell
.\scripts\Generate-InventoryReport.ps1 -OutputPath ".\sample-output\inventory.csv"
```

