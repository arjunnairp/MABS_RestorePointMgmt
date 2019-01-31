#——————————————————————————————–#
# Script_Name : MABD_RPDel.ps1
# Description : Gets input from user to delete selected Recovery point; Deletes only one recovery point per operation
# Version : 1
# Date : January 2019
# Created by Arjun N
# Disclaimer:
# THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
# AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
#——————————————————————————————-#
$Backup_server = Read-Host("Enter Backup Server")
$pgList = get-protectiongroup $Backup_server
$i=0;foreach($pg in $pgList){write-host (“{0} : {1}” -f $i, $pg.friendlyname);$i++}

$pglistval = Read-Host("Enter Protection group index number")
$dsList = get-datasource $pglist[$pglistval]
$i=0;foreach($ds in $dsList){write-host (“{0} : {1} : {2} : {3}” -f $i, $ds.name, $ds.Computer, $ds.DiskAllocation);$i++}

$dslistval = Read-Host("Enter data source index number")
$rpList = get-recoverypoint $dslist[$dslistval]
$i=0;foreach($rp in $rpList){write-host (“{0} : {1}” -f $i, $rp.representedpointintime);$i++}

$rplistval = Read-Host("Enter recovery point index number")
remove-recoverypoint -recoverypoint $rpList[$rplistval] -ForceDeletion