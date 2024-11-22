# Load the CSV file
$users = Import-Csv -Path "C:\temp\distrocleanup.csv"


# Loop through each user
foreach ($user in $users) {
    $email = $user.EmailAddress

    # Find all distribution groups the user is a member of
    $groups = Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember -Identity $_.Identity | Where-Object {$_.PrimarySmtpAddress -eq $email}) }

    foreach ($group in $groups) {
        # Remove the user from the distribution group
        Remove-DistributionGroupMember -Identity $group.Identity -Member $email -Confirm:$false
        Write-Host "Removed $email from $($group.DisplayName)"
    }
}