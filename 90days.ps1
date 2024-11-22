# Define the output file path
$outputFile = "C:\temp\AD_Users_Not_LoggedIn_Last_90_Days.csv"

# Calculate the date 90 days ago
$daysAgo = (Get-Date).AddDays(-90)

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all users who have not logged in for the last 90 days
$inactiveUsers = Get-ADUser -Filter * -Property LastLogonDate, Enabled | Where-Object {
    ($_.LastLogonDate -eq $null) -or ($_.LastLogonDate -lt $daysAgo)
}

# Prepare the output data
$exportData = $inactiveUsers | Select-Object Name, SamAccountName, Enabled, LastLogonDate

# Export to CSV
$exportData | Export-Csv -Path $outputFile -NoTypeInformation

# Output to console
Write-Host "Exported users who have not logged in for the last 90 days to $outputFile"
