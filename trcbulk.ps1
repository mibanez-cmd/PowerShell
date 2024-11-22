# Define function to generate random password with length of exactly 12 characters 
Function Generate-RandomPassword {
    $lowercase = "abcdefghijklmnopqrstuvwxyz"
    $uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $digits = "0123456789"
    $special = "!@#$%^&*"

    # Start with at least one character from each required set to meet complexity
    $password = ($lowercase | Get-Random -Count 3) +    # 3 lowercase letters
                ($uppercase | Get-Random -Count 3) +    # 3 uppercase letters
                ($digits | Get-Random -Count 3) +       # 3 digits
                ($special | Get-Random -Count 3)        # 3 special characters

    # Shuffle and trim to ensure exactly 12 characters
    $password = ($password.ToCharArray() | Sort-Object { Get-Random }) -join ''
    return $password.Substring(0, 12)
}

# Import CSV file
$users = Import-Csv -Path "C:\TEMP\TestUsers.csv"

# Initialize array to store results
$results = @()

# Loop through each user in the CSV
foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $title = $user.Title
    $department = $user.Department
    $company = $user.Company

    # Initialize SamAccountName generation
    $samAccountName = ""
    $maxLastNameLength = 8
    $retryCount = 0
    $prefixLength = 1

    do {
        # Adjust prefix length and last name truncation
        $firstNamePart = $firstName.Substring(0, [Math]::Min($prefixLength, $firstName.Length))
        $lastNamePart = $lastName.Substring(0, [Math]::Min($maxLastNameLength, $lastName.Length))

        # Generate SamAccountName
        $samAccountName = ($firstNamePart + $lastNamePart).Substring(0, [Math]::Min(8, $firstNamePart.Length + $lastNamePart.Length))

# Check for existing SamAccountName and adjust if necessary
if (Get-ADUser -Filter {SamAccountName -eq $samAccountName}) {
    if ($prefixLength -lt $firstName.Length) {
        $prefixLength++
    } else {
        $maxLastNameLength--
    }
    $retryCount++
} else {
    break
}
    } while ($retryCount -lt 10 -and ($prefixLength + $maxLastNameLength -ge 1))

    if ($retryCount -ge 10) {
        $results += [PSCustomObject]@{
            Name = "$firstName $lastName"
            EmailAddress = ""
            SamAccountName = ""
            Department = $department
            Title = $title
            Company = $company
            Password = ""
            CreationStatus = "Failed: Unable to generate unique SamAccountName"
        }
        Write-Host "Unable to generate unique SamAccountName for $firstName $lastName." -ForegroundColor Yellow
        continue
    }

# Generate unique UserPrincipalName (email) by progressively removing letters from the last name if needed
$domain = "@oattravel.com"
$retryCount = 0
$userPrincipalName = ""
$prefixLength = 1
$maxLastNameLength = $lastName.Length

do {
    # Adjust prefix length and last name truncation
    $firstNamePart = $firstName.Substring(0, [Math]::Min($prefixLength, $firstName.Length))
    $lastNamePart = $lastName.Substring(0, [Math]::Min($maxLastNameLength, $lastName.Length))

    # Generate UserPrincipalName
    $userPrincipalName = ($firstNamePart + $lastNamePart).ToLower() + $domain

    # Check if UserPrincipalName already exists and adjust if necessary
    if (Get-ADUser -Filter {UserPrincipalName -eq $userPrincipalName}) {
        if ($prefixLength -lt $firstName.Length) {
            $prefixLength++
        } else {
            $maxLastNameLength--
        }
        $retryCount++
    } else {
        break
    }
} while ($retryCount -lt 10 -and ($prefixLength + $maxLastNameLength -ge 1))

if ($retryCount -ge 10) {
    $results += [PSCustomObject]@{
        Name = "$firstName $lastName"
        EmailAddress = ""
        SamAccountName = $samAccountName
        Department = $department
        Title = $title
        Company = $company
        Password = ""
        CreationStatus = "Failed: Unable to generate unique UserPrincipalName"
    }
    Write-Host "Unable to generate unique UserPrincipalName for $firstName $lastName." -ForegroundColor Yellow
    continue
}

    # Generate random password that meets AD complexity requirements
    $password = Generate-RandomPassword
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

    # Create AD user
    $userParams = @{
        SamAccountName = $samAccountName
        UserPrincipalName = $userPrincipalName
        Name = "$firstName $lastName"
        displayName = "$firstName $lastName"
        GivenName = $firstName
        Surname = $lastName
        Enabled = $true
        AccountPassword = $securePassword
        EmailAddress = $userPrincipalName
        Department = $department
        Company = $company
        Title = $title
    }

    try {
        $newUser = New-ADUser @userParams -ErrorAction Stop
        $results += [PSCustomObject]@{
            Name = "$firstName $lastName"
            EmailAddress = $userPrincipalName
            SamAccountName = $samAccountName
            Department = $department
            Title = $title
            Company = $company
            Password = $password
            CreationStatus = "Success"
        }
        Write-Host "User $($newUser.SamAccountName) created successfully." -ForegroundColor Green
    } catch {
        $results += [PSCustomObject]@{
            Name = "$firstName $lastName"
            EmailAddress = $userPrincipalName
            SamAccountName = $samAccountName
            Department = $department
            Title = $title
            Company = $company
            Password = $password
            CreationStatus = "Failed: $_"
        }
        Write-Host "Failed to create user $($userParams['SamAccountName']). Error: $_" -ForegroundColor Red
    }
}

# Ensure the output directory exists
$outputDir = "C:\temp"
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory
}

# Generate a unique file name with the current date
$baseFileName = "GeneratedUsers_$(Get-Date -Format 'yyyyMMdd')"
$filePath = "$outputDir\$baseFileName.csv"
$counter = 1

# Check if file exists and create a unique name by appending a counter if needed
while (Test-Path $filePath) {
    $filePath = "$outputDir\$baseFileName_$counter.csv"
    $counter++
}

# Export results to CSV
$results | Select-Object Name, EmailAddress, SamAccountName, Department, Title, Company, Password, CreationStatus |
Export-Csv -Path $filePath -NoTypeInformation -Force

Write-Host "Results exported to $filePath"
