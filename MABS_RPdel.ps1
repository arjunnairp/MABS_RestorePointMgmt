#——————————————————————————————–#
# Script_Name : MABS_RPDel.ps1
# Description : Gets input from user to delete one or more recovery points.
# Version : 2.4
# Changes:
# v2: a. Deletes multiple recover points of the same volume b. Loops through the scipt again as per request
# v2.1: Removed Disk Allocation info to simplify the output of list of recovery points
# v2.2: Added -ForceDeletion parameter to force-remove recovery points that might not get deleted sometimes
# v2.3: Added Recursive loop function call for removing recovery points
# v2.4: Added ErrorActionPreference for exiting script in-case of an unexpected input
# v2.4: Added picking up Backup server from local powershell console using environment variables
# Date : January 2019
# Created by Arjun N
# Disclaimer:
# THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
# AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
#——————————————————————————————-#
$ErrorActionPreference = "Stop"
$Backup_server = Read-Host("Enter Backup Server(Hit Return if this is the backup server)")
if($Backup_server.Length -eq "")
{ $Backup_server = $env:COMPUTERNAME
}
$rpdel1 = {
$pgList = get-protectiongroup $Backup_server
$i=0;foreach($pg in $pgList){write-host (“{0} : {1}” -f $i, $pg.friendlyname);$i++}

$pglistval = Read-Host("Enter Protection group index number")
$dsList = get-datasource $pglist[$pglistval]
$i=0;foreach($ds in $dsList){write-host (“{0} : {1} : {2} : {3}” -f $i, $ds.name, $ds.Computer, $ds.DiskAllocation);$i++}

$dslistval = Read-Host("Enter data source index number")
$rpList = get-recoverypoint $dslist[$dslistval]
$i=0;foreach($rp in $rpList){write-host (“{0} : {1}” -f $i, $rp.representedpointintime);$i++}

<#
$rplistval = Read-Host("Enter recovery point index number")
remove-recoverypoint -recoverypoint $rpList[$rplistval] -ForceDeletion
#>

Write-Host "`nEnter the index value of the first recovery point to be deleted"
$FromWhich = Read-Host


Write-Host "`nEnter the number of recovery points to be deleted starting from" $FromWhich
$HowMany = Read-Host

for($k=1; $k -le $HowMany; $k=$k+1)
{
remove-recoverypoint -recoverypoint $rpList[$FromWhich] -confirm:$False -ForceDeletion ;
[int]$FromWhich=[int]$FromWhich+1}
}

&$rpdel1

$loopthrough = {
$again = Read-Host("Remove more recovery points?(Y/N)")
if($again -eq "y")
{ &$rpdel1
  &$loopthrough
}
else {
Disconnect-DPMServer
Write-Host("Quitting...");
Start-Sleep -Seconds 5
exit
}
}

&$loopthrough
