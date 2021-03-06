param
(
[string] $URL,
[boolean] $WriteToFile = $false
)
 
cls
#Get all lists in farm
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$arrSysLibs = @("Converted Forms", 
				"Customized Reports", 
				"Documents", 
				"Form Templates",
				"Images", 
				"List Template Gallery", 
				"Master Page Gallery", 
				"Pages",
				"Reporting Templates", 
				"Site Assets", 
				"Site Collection Documents", 
				"Site Collection Images", 
				"Site Pages", "Solution Gallery", 
				"Style Library", 
				"Theme Gallery", 
				"Web Part Gallery", 
				"wfpub"
				)
 
#Counter variables
$webcount = 0
$listcount = 0
 
#if ($WriteToFile -eq $true) {
#	$outputPath = Read-Host "Outputpath (e.g. C:directoryfilename.txt)"
#	}

if (!$URL) {
	#Grab all webs
	$webs = (Get-SPSite -limit all | Get-SPWeb -Limit all -ErrorAction SilentlyContinue)
	} 
else {
	$webs = Get-SPWeb $URL
	}

if ($webs.count -ge 1 -OR $webs.count -eq $null) {
	 foreach ($web in $webs) {
	 	$Web
		#Grab all lists in the current web
		$lists = $web.Lists
		Write-Host "Website"$web.url -ForegroundColor darkgreen
		if ($WriteToFile -eq $true) {
			Add-Content -Path $outputPath -Value "Website $($web.url)"
			}
		$Web.Title
		$lists.Count
		$getlistError = 0
		$lists | %{
			if (!($arrSysLibs.Contains($_.Title))) {

				$listcount += 1
				Write-Host " – "$_.Title
				try {
					$Web.Url + '/' + $_.Title
					$gl = $webs.GetList($web.url + '/' + $_.Title)
					}
				catch {
					$_.Exception
					$getlistError += 1
					}
				if ($WriteToFile -eq $true) {
					Add-Content -Path $outputPath -Value " – $($_.Title)"
					}
				}	
			}
		$webcount += 1
		$web.Dispose()
		}
	#Show total counter for checked webs &amp; lists
	Write-Host "Amount of webs checked:"$webcount
	Write-Host "Amount of lists:"$listcount
	}
else {
	Write-Host "No webs retrieved, please check your permissions" -ForegroundColor Red -BackgroundColor Black
	}
