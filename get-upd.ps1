cls
$objSession = New-Object -com "Microsoft.Update.Session"
$objSearcher = $objSession.CreateUpdateSearcher()
#$results = 
$objSearcher.search($results)
$results.updates.count

#$installer = New-Object -com "Microsoft.Update.Installer"
#
#$installer.Updates = $results.updates
#
#foreach ($update in $objresults)
#{
#    $objInstaller.install()
#}
#