# Login to Azure AD
Connect-AzureAD # If using AzureAD module
# Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All" # If using Microsoft.Graph module

# Path to your CSV file containing email addresses
$csvFilePath = "C:\temp\azuregroups.csv"

# Group IDs (replace with the actual GUIDs of the groups)
$groupIds = @(
    "4c798eff-61d6-4282-b93c-f82c85b66895",
    "bd96a078-6973-4265-aab2-03d3a0e05d43",
    "d6ad9490-1f06-4746-81d6-e8db5942d67a",
    "31631850-c2a0-4178-ad8a-693ccb29fb8a",
    "b9e01831-825c-45fd-8539-551b570e0a1f"
)

# Import the user email addresses from the CSV file
$users = Import-Csv -Path $csvFilePath

# Loop through each user and add them to the groups
foreach ($user in $users) {
    $email = $user.Email

    # Get the user object by their email address
    $userObj = Get-AzureADUser -Filter "UserPrincipalName eq '$email'" # If using AzureAD module
    # $userObj = Get-MgUser -UserPrincipalName $email # If using Microsoft.Graph module

    if ($userObj) {
        Write-Host "Adding $email to groups..."

        # Loop through each group ID and add the user to the group
        foreach ($groupId in $groupIds) {
            try {
                Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $userObj.ObjectId # AzureAD module
                # Add-MgGroupMember -GroupId $groupId -UserId $userObj.Id # Microsoft.Graph module
                Write-Host "User $email added to group $groupId"
            }
            catch {
                Write-Host "Error adding $email to group $groupId $_"
            }
        }
    } else {
        Write-Host "User $email not found in Azure AD."
    }
}

Write-Host "Script execution completed."
