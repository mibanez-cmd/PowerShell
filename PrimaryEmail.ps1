# Connect to Exchange Online
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Authentication Basic -AllowRedirection -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking

# Define the user's current and new email addresses
$OldEmail = "agoodman@oattravel.onmicrosoft.com"
$NewEmail = "agoodman@oattravel.com"

# Set the new primary email address
Set-Mailbox -Identity $OldEmail -PrimarySmtpAddress $NewEmail

# Optional: Add the old address as a secondary alias (proxy address)
Set-Mailbox -Identity $NewEmail -EmailAddresses @{add="SMTP:$OldEmail"}

# Verify the changes
Get-Mailbox $NewEmail | Select-Object DisplayName, PrimarySmtpAddress, EmailAddresses

# Disconnect from the session
Remove-PSSession $Session
