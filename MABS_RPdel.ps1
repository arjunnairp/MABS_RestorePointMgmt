#——————————————————————————————–#
# Script_Name : MABS_RPDel.ps1
# Description : Gets input from user to delete one or more recovery points.
# Version : 1.0-A
# Date : October 2019
# Created by Arjun N
# Disclaimer:
# THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
# AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE SCRIPT.
#——————————————————————————————-#

param (

[string]$Backup_server = (Read-Host -prompt 'Enter Backup Server (Hit Return if this is the backup server)'),
[INT32]$MaxRpt = (Read-Host -prompt 'Maximum Recovery points?')
)

Start-Transcript -Path "$pwd\mabslog$(get-date -f yyyy-MM-dd-hh-mm-ss).log"

<# *** Fail-Safe switch - To be used when script needs to be run manually. ***

while($MaxRpt -le 10)
{ 
  $failsafe =   Read-Host("Seriously? Less than 10? Continue?(Y/N)")
  if ($failsafe -eq "N")
{   Write-Host Exitting....
    Pause 5
    exit}

Elseif (($MaxRpt -eq 0) -and ($failsafe -eq "Y"))
{  Write-Host Cant continue with cleanup... Exitting....
    Pause 5
    exit
}
else
{break}
}

*** Fail safe part ends *** #>

if($Backup_server.Length -eq "")
{ $Backup_server = $env:COMPUTERNAME
}

$pgList = get-protectiongroup $Backup_server
$pgcount = $pgList.Count

for($pgc=0; $pgc -lt $pgcount; $pgc=$pgc+1)
{
$pglistval = $pgc
$dsList = get-datasource $pglist[$pglistval]
$dscount = $dsList.count
    for($dsc=0; $dsc -lt $dscount; $dsc=$dsc+1)
    {
    $dslistval = $dsc

    $rpList = get-recoverypoint $dslist[$dslistval]
    $rpcount = $rpList.Count
    if ($rpcount -gt $MaxRpt)
    { Write-Host `n $rpcount Recovery points are avaialble for $dsList[$dslistval].DatasourceName on $dsList[$dslistval].computer
        for ($z=1; $z -le $rpcount; $z++)
        { Write-Host $rpList[$z].backuptime
        }
    }
    

    else 
    { Write-Host `n Only $rpcount recovery points avaialble for $dsList[$dslistval].DatasourceName on $dsList[$dslistval].computer
      <# **** Uncomment out the below block for additional warnings - Not inteneded when script is run as a scheduled task
      Read-Host ("`nFine to continue with other datasources/servers ?")
      #>
    }
    
    $FromWhich = 0
    $HowMany = $rpcount - $MaxRpt
        for($k=1; $k -le $HowMany; $k=$k+1)
        {
        remove-recoverypoint -recoverypoint $rpList[$FromWhich] -confirm:$False -ForceDeletion ;
        Write-Host Deleted Recovery point $FromWhich created at $rpList[$FromWhich].BackupTime of $rpList[$FromWhich].DataSource.Name from $rpList[$FromWhich].DataSource.Computer 

        [int]$FromWhich=[int]$FromWhich+1
        }
    }
}