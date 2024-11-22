# Import CSV file
$csvFile = "C:\temp\updateorg.csv"
$userData = Import-Csv $csvFile

# Loop through each user and update attributes
$results = @()
foreach ($user in $userData) {
    $samAccountName = $user.SamAccountName
    $department = $user.Department
    $manager = $user."Supervisor SAMAcctName"
    $title = $user."Job Title"
    $emailAddress = $user."Employee Email Address"
    $employeeID = $user."Employee Number"
    
    # Update user attributes
    Set-ADUser -Identity $samAccountName -Department $department -Manager $manager -Title $title  -EmailAddress $emailAddress -EmployeeID $employeeID
    
    # Get updated user details
    $updatedUser = Get-ADUser -Identity $samAccountName -Properties Department, Manager, Title, Company, EmailAddress, EmployeeID
    
    # Add results to array
    $result = @{
        SamAccountName = $samAccountName
        Department = $updatedUser.Department
        Manager = $updatedUser.Manager
        Title = $updatedUser.Title
        EmailAddress = $updatedUser.Mail
        EmployeeID = $updatedUser.EmployeeID
    }
    $results += New-Object PSObject -Property $result
}

# Export results to CSV
$results | Export-Csv -Path "C:\temp\orgchanges11182024.csv" -NoTypeInformation