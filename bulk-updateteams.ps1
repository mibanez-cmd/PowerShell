#Parameters
$CSVPath = "C:\Temp\TRCTeam.csv"
$TeamDisplayName = "TRC-Agents"
 
Try {
    #Connect to Microsoft Teams
    Connect-MicrosoftTeams
 
    #Get Team ID from Display Name
    $TeamID = Get-Team | Where {$_.DisplayName -eq $TeamDisplayName} | Select -ExpandProperty GroupID
 
    #Get users from the CSV
    $TeamUsers = Import-Csv -Path $CSVPath
 
    #Iterate through each user from the CSV and add to Teams
    $TeamUsers | ForEach-Object {
        Try {
            Add-TeamUser -GroupId $TeamID -User $_.Email -Role $_.Role
            Write-host "Added User:"$_.Email -f Green
        }
        Catch {
            Write-host -f Red "Error Adding User to the Team:" $_.Exception.Message
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}


