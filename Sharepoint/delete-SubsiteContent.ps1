cls
Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue

function Get-DocInventory([string]$siteUrl) {
	$site = New-Object Microsoft.SharePoint.SPSite $siteUrl

	$web = Get-SPWeb -Identity $siteUrl

	$web
	foreach ($list in $web.get_Lists()) {
		$list.title
		if ($list.Title.ToString() -Match 'Quality Management') {
			
#			if ($list.BaseType -ne “DocumentLibrary”) {
#				continue
#				}


# documents ditribution all = shared with LNB

		$list.items.count
		for ($i = $list.items.count - 1; $i -ge 0; $i--) {
#		$list.GetItems() | %{
			$list.items[$i].Name
			$list.items[$i].delete()
#			$list.update()
			}
		$list.items.count
		}
		}
	$web.Dispose();
	$site.Dispose()
	}

Get-DocInventory "http://copsp01n/dms/operations" #| Out-GridView
#Get-DocInventory "http://cocsp02" | Export-Csv -NoTypeInformation -Path "c:\temp\Document_Detail_Report_IT.csv"

