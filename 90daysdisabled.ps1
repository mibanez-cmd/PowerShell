# Define the output file path
$outputFile = "C:\Temp\Disabled_AD_Users_Not_LoggedIn_Last_90_Days.csv"

# Calculate the date 90 days ago
$daysAgo = (Get-Date).AddDays(-90)

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all disabled users who have not logged in for the last 90 days
$inactiveDisabledUsers = Get-ADUser -Filter {Enabled -eq $false} -Property LastLogonDate | Where-Object {
    ($_.LastLogonDate -eq $null) -or ($_.LastLogonDate -lt $daysAgo)
}

# Prepare the output data
$exportData = $inactiveDisabledUsers | Select-Object Name, SamAccountName, LastLogonDate

# Export to CSV
$exportData | Export-Csv -Path $outputFile -NoTypeInformation

# Output to console
Write-Host "Exported disabled users who have not logged in for the last 90 days to $outputFile"
