#Parameters
$SourceUserAccount = "user1@domain.com"
$TargetUserAccount = "user2@domain.com"

# import the Azure Active Directory module in order to be able to use Get-AzureADUserMembership and Add-AzureADGroupMember cmdlet
Install-Module AzureAD
 
#Connect to Azure AD
Connect-AzureAD
 
#Get the Source and Target users
$SourceUser = Get-AzureADUser -Filter "UserPrincipalName eq '$SourceUserAccount'"
$TargetUser = Get-AzureADUser -Filter "UserPrincipalName eq '$TargetUserAccount'"
 
#Check if source and Target users are valid
If($SourceUser -ne $Null -and $TargetUser -ne $Null)
{
    #Get All memberships of the Source user
    $SourceMemberships = Get-AzureADUserMembership -ObjectId $SourceUser.ObjectId | Where-object { $_.ObjectType -eq "Group" }
 
    #Get-AzureADUserOwnedObject -ObjectId $SourceUser.ObjectId
 
    #Loop through Each Group
    ForEach($Membership in $SourceMemberships)
    {
        #Check if the user is not part of the group
        $GroupMembers = (Get-AzureADGroupMember -ObjectId $Membership.Objectid).UserPrincipalName
        If ($GroupMembers -notcontains $TargetUserAccount)
        {
            #Add Target user to the Source User's group
            Add-AzureADGroupMember -ObjectId $Membership.ObjectId -RefObjectId $TargetUser.ObjectId
            Write-host "Added user to Group:" $Membership.DisplayName
        }
    }
}
Else
{
    Write-host "Source or Target user is invalid!" -f Yellow
}
