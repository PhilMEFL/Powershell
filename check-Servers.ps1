Import-Module ActiveDirectory

# —————————————————————————
# Name:   Invoke-Ternary
# Alias:  ?:
# Author: Karl Prosser
# Desc:   Similar to the C# ? : operator e.g.
#            _name = (value != null) ? String.Empty : value;
# Usage:  1..10 | ?: {$_ -gt 5} {“Greater than 5;$_} {“Not greater than 5″;$_}
# —————————————————————————
set-alias ?: Invoke-Ternary -Option AllScope -Description “PSCX filter alias”
filter Invoke-Ternary ([scriptblock]$decider, [scriptblock]$ifTrue, [scriptblock]$ifFalse) {
	if (&$decider) { 
		&$ifTrue
   		}
	else { 
		&$ifFalse 
		}
	}

function SendMail {
	$smtpServer = 'copexc01'
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$emailFrom = 'support@gpco.be'
	$subject = 'Email Subject'
	foreach ($line in Get-Content 'D:\Scripts\lowdisk.txt') {
		$body += '$line `n'
		}
	$smtp.Send($EmailFrom,'support@gpco.be',$subject,$body)
	$body = ''
	}

Function format-DiskSize() {
	[cmdletbinding()]
		Param ([long]$Type)

	If ($Type -ge 1TB) {
		[string]::Format("{0:0.00} TB", $Type / 1TB)
		}
	ElseIf ($Type -ge 1GB) {
		[string]::Format("{0:0.00} GB", $Type / 1GB)
		}
	ElseIf ($Type -ge 1MB) {
		[string]::Format("{0:0.00} MB", $Type / 1MB)
		}
	ElseIf (
		$Type -ge 1KB) {[string]::Format("{0:0.00} KB", $Type / 1KB)
		}
	ElseIf ($Type -gt 0) {
		[string]::Format("{0:0.00} Bytes", $Type)
		}
	Else {
		""
		}
	} # End of function

#cls
#$strOutFile = 'C:\Temp\Report.htm'
$strOutFile = 'C:\Users\pmartin\OneDrive\IGT\GPCO\Projects\GPCOReports\Report.aspx'
#$strOutFile = '\\copwa01\ServersReport\Default.aspx'
if (Test-Path $strOutFile) {
	$arrTemp = $strOutFile.split('.')
	$strNew = "{0}{1}.{2}" -f $arrTemp[0], ((Get-Date).AddDays(-1)).toString('yyyyMMdd'), $arrTemp[1] 
	Rename-Item $strOutFile $strNew -Force
	}
$HTMLheader = '<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>'
$HTMLheader | Out-File $strOutFile 
$HTMLheader  = '<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">'
$HTMLheader | Out-File $strOutFile -Append
$HTMLTitle = "<h1>{0}'s servers daily report on {1}</h1>" -f $env:USERDOMAIN, (Get-Date).toShortDateString() | Out-File $strOutFile -Append

$i = 1
$Srvs = get-adcomputer -Filter * -properties * -SearchBase "OU=Domain Controllers,DC=gpco,DC=local"
$Srvs += get-adcomputer -Filter * -properties * -SearchBase "OU=CO_Servers,DC=gpco,DC=local"

$Srvs = $Srvs | where {(!($_.servicePrincipalName -match 'VirtualServer'))} | sort Name 
$Srvs | %{
	$strServer = $_.Name
#	if ($_.Name -eq 'COPSQL01-1') {
#		$tata = 'toto'
#		}
	Write-Progress -Activity "Collecting info on server $($strServer)" -status "Processing server $($StrServer) #$i of $($Srvs.count)" -percentComplete ($i / $Srvs.count*100)
	$strBtn = "'Button{0}'" -f $i
	$strTBL = "'Table{0}'" -f $i
	if (Test-Connection($strServer) -quiet ) {
		$wmiDrives = Get-WmiObject -ComputerName $strServer Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
		$strDisk = "{0} disk{1}" -f ($wmiDrives.count | ?: {$_} {$wmiDrives.count} {1}), ($wmiDrives.count | ?: {$_-gt 1} {'s'} {''})
#		'</asp:Table>' | Out-File $strOutFile -Append
		
$strServer
		$objError = Get-WinEvent -ComputerName $strServer -FilterHashtable @{logname='system'; StartTime=(get-date).AddHours(-24)}
		$objError = $objError | where {$_.level -lt 4}
		$strCSS = 'warning'
		if (!$objError.count) {
			$strCss = 'ok'
#			"<asp:Table runat='server' ID=$strTBL CSSClass='ok'>
#				<asp:TableHeaderRow  CSSClass='ok'>
#					<asp:TableCell runat='server'>$strServer OK</asp:TableCell>
#				</asp:TableHeaderRow>" | Out-File $strOutFile -Append
			}
		if ($objError | Where-Object {$_.LevelDisplayName -like 'Error'}) {
			$strCSS = 'error'
			}
		$strErrMsg = "{0} {1}{2}" -f $objError.Count.ToString() ,$strCSS, ($objError.count | ?: {$_ -gt 1} {'s'} {''})
		$strStatus = if ($strCss -eq 'OK') {
				 		'OK'
						}
					else {
						"<asp:Button runat='server' ID=$strBtn Text='$strErrMsg' OnClick='LinkButton_Click'/>"
						}
						
#		$strError = "<asp:LinkButton runat='server' ID=$strLB OnClick='LinkButton_Click'>{0} {1}{2}</asp:LinkButton>" -f $objError.Count.ToString() ,$strError, ($objError.count | ?: {$_ -gt 1} {'s'} {''})
		"<asp:Table runat='server' ID=$strTBL>" | Out-File $strOutFile -Append
 		"<asp:TableHeaderRow runat='server' TableSection='TableHeader' CssClass='$strCss'>
			<asp:TableHeaderCell>$strServer</asp:TableHeaderCell>
			<asp:TableHeaderCell>$strDisk</asp:TableHeaderCell>
			<asp:TableHeaderCell>$strStatus</asp:TableHeaderCell>
			<asp:TableHeaderCell>&nbsp</asp:TableHeaderCell>
		</asp:TableHeaderRow>

		<asp:TableRow runat='server'>
				<asp:TableCell runat='server'>Drive</asp:TableCell>
				<asp:TableCell runat='server'>Capacity</asp:TableCell>
				<asp:TableCell runat='server'>Free Space</asp:TableCell>
				<asp:TableCell runat='server'>% Free</asp:TableCell>  
			</asp:TableRow>" | Out-File $strOutFile -Append
		$wmiDrives | %{
			$numFree = ($_.FreeSpace / $_.Size * 100)
			$strCss = ''
			if ($numFree -lt 10) {
				$strCss = 'error'
				}
			elseif ($numFree -lt 25) {
				$strCss = 'warning'
				}
			"<asp:TableRow CssClass='$strCss'>
				<asp:TableCell>{0}</asp:TableCell>
				<asp:TableCell>{1}</asp:TableCell>
				<asp:TableCell>{2}</asp:TableCell>
				<asp:TableCell>{3:N2}%</asp:TableCell>
			</asp:TableRow>" -f $_.DeviceID, (format-DiskSize($_.Size)), (format-DiskSize($_.FreeSpace)), ($_.FreeSpace / $_.Size * 100) | Out-File $strOutFile -Append
			}
		if (!($strStatus -eq 'ok')) {
    		"<asp:TableRow runat='server' CssClass='hidden'>
					<asp:TableCell runat='server'>TimeCreated</asp:TableCell>
					<asp:TableCell runat='server'>Id</asp:TableCell>
					<asp:TableCell runat='server'>LevelDisplayName</asp:TableCell>
					<asp:TableCell runat='server'>Message</asp:TableCell>  
				</asp:TableRow>" | Out-File $strOutFile -Append
			$objError | %{
				$strCss = $_.LevelDisplayName.ToLower()
				"<asp:TableRow CssClass='hidden'>
					<asp:TableCell>{0}</asp:TableCell>
					<asp:TableCell>{1}</asp:TableCell>
					<asp:TableCell>{2}</asp:TableCell>
					<asp:TableCell>{3}</asp:TableCell>
				</asp:TableRow>" -f $_.TimeCreated, $_.ID, $_.LevelDisplayName, $_.Message | Out-File $strOutFile -Append
				}
#		$strErrors =  $objError | Out-string
			}
	#			send-mailmessage -to "Notifications@gpco.be" -from "Philippe.martin@gpco.be" -subject $strSubject -Body $strErrors -SmtpServer copexc01
			}
	else {
		"<asp:Table runat='server' ID=$strTBL>
			<asp:TableHeaderRow CSSClass='unreach'>
				<asp:TableCell runat='server'>$strServer unreachable</asp:TableCell>
			</asp:TableHeaderRow>" | Out-File $strOutFile -Append
		}
	'</asp:Table>' | Out-File $strOutFile -Append
	$i++
	}

'</asp:Content>' | Out-File $strOutFile -Append
#$strOutFile | ConvertTo-Html -Head $HTMLheader -body $HTMLTitle #| Out-File c:\Temp\serverReport.html
Invoke-Expression $strOutFile
