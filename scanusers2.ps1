Connect-PowerBIServiceAccount -Environment USGovHigh
Connect-AzureAD -AzureEnvironmentName AzureUSGovernment

$workspaces = (Get-PowerBIWorkspace).Id

ForEach($workspace in $workspaces) {
    $url =  $workspace | ForEach-Object {"https://api.high.powerbigov.us/v1.0/myorg/admin/groups/" + $_ + "/users"}
    $invoke = $url | ForEach-Object {Invoke-PowerBIRestMethod -Method GET -Url $_ } | ConvertFrom-Json -Depth 2
    $member = $invoke.value.emailAddress| Sort-Object -Unique
    $securityMember = (Get-AzureADGroupMember -ObjectId 63150c38-e988-45dd-93da-4991fc924206).UserPrincipalName
    $removeMembers = $member | Where-Object { $_ –ne $securityMember }
    $removeMembers | ForEach-Object{"Remove-PowerBIWorkspaceUser -Id $($workspace) -UserPrincipalName $($_)"}

}

# Remove-PowerBIWorkspaceUser -Id $workspace -UserPrincipalName $_
# $workspace | ForEach-Object {Remove-PowerBIWorkspaceUser -Id $_ -UserPrincipalName $removeMembers}
