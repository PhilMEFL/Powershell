cls
Get-SPSite | Get-SPWeb | %{
    $_.url
	$_.SiteGroups
	$_.RoleAssignments.Member.Name
	$tata = 'toto'
#    $_.AssociatedGroups | %{
#        $_
#        }
    } 