<#
.SYNOPSIS
Simulates a user onboarding checklist.

.DESCRIPTION
This does not create real accounts. It produces a structured onboarding checklist.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FirstName,

    [Parameter(Mandatory = $true)]
    [string]$LastName,

    [Parameter(Mandatory = $true)]
    [string]$Department,

    [string]$OutputPath
)

$username = ($FirstName.Substring(0,1) + $LastName).ToLower()
$email = "$username@example.com"

$checklist = @(
    [PSCustomObject]@{ Step = 1; Task = "Create user account"; Owner = "IT"; Status = "Pending"; Notes = $username }
    [PSCustomObject]@{ Step = 2; Task = "Assign email address"; Owner = "IT"; Status = "Pending"; Notes = $email }
    [PSCustomObject]@{ Step = 3; Task = "Assign baseline groups"; Owner = "IAM"; Status = "Pending"; Notes = $Department }
    [PSCustomObject]@{ Step = 4; Task = "Enroll endpoint"; Owner = "Endpoint Team"; Status = "Pending"; Notes = "Laptop or workstation" }
    [PSCustomObject]@{ Step = 5; Task = "Apply least privilege access"; Owner = "Security"; Status = "Pending"; Notes = "Role based access" }
    [PSCustomObject]@{ Step = 6; Task = "Document ticket closure"; Owner = "Service Desk"; Status = "Pending"; Notes = "Attach validation evidence" }
)

Write-Host "Mock onboarding checklist for $FirstName $LastName"
$checklist | Format-Table -AutoSize

if ($OutputPath) {
    $checklist | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Onboarding checklist exported to $OutputPath"
}
