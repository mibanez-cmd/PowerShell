$UserUPNs = Import-CSV C:\temp\11122024.csv
$GroupUPN = Import-CSV C:\temp\SalesDistro.csv |
foreach { ($GroupUPN = $_.GroupUPN)
Foreach($UserUPN in $UserUPNs.Email)
{
Write-Progress -Activity "Adding $UserUPN to $GroupUPN"  
Add-DistributionGroupMember -Identity $GroupUPN -Member $UserUPN  
}
}