# Path to the CSV files
$samAccountCsvPath = "C:\Temp\11122024.csv"
$securityGroupsCsvPath = "C:\Temp\securitygroups.csv"

# Import CSV files
$samAccounts = Import-Csv $samAccountCsvPath
$securityGroups = Import-Csv $securityGroupsCsvPath

# Iterate through each SamAccount
foreach ($samAccount in $samAccounts) {
    $samAccountName = $samAccount.SamAccountName

    # Iterate through each security group
    foreach ($securityGroup in $securityGroups) {
        $groupName = $securityGroup.GroupName

        # Add SamAccount to security group
        Add-ADGroupMember -Identity $groupName -Members $samAccountName
    }
}