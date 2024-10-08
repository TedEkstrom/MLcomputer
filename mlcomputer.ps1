﻿
$user = WHOAMI /UPN
$mode = "multi" 
$showMode = "singel"
$SingelComputer = ""
$ShowSingelComputer = ""
$changeUser = $true

while (1) {
   
    $input = ""

    if ( $mode -eq "singel" ) {
        $ShowSingelComputer = "[select: mlcomputer00$SingelComputer]"
    } else {
        $ShowSingelComputer = ""
    }

    while (!$input) {
        Write-Host "

        current user: $user, in $($mode)mode

            POWERED ON                                           SEND COMMAND
            [1] Check if on                                      [13] Send command

            NVIDIA-SMI                                           CONNECT
            [2] Check nvidia-smi                                 [14] Connect with ssh
            [3] Check nvidia-smi in docker                       
                                                                 MODE
            CONTAINER                                            [15] Computer to connect (in singelmode)
            [4] Check for docker images                          [16] Select $($showMode)mode
            [5] Check for docker containers                      
            [6] Remove all docker images                         USER
            [7] Remove all docker containers                     [17] Change user
                                                                 [18] Update password
            IP ADDRESS                                           
            [8] Check IP-address                                 Check user
                                                                 [19] In RDP group
            UPDATE                                               [20] Logged in user                                            
            [9] Check for security update                        [21] Kick out users (need sudo)
            [11] Check full upgrade                              
            [10] Security update                                 [22] Exit
            [12] Full upgrade

            
            
        "
        $input = Read-Host -Prompt "choose? $ShowSingelComputer"
        Write-Host ""
    }

    switch ($input) {
        
        1 { # Check if on
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; ; ping mlcomputer00$_ -n 1; Write-Host ""}  
            } else {
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; ; ping mlcomputer00$_ -n 1; Write-Host ""
            }
          }

        2 { # Check nvidia-smi
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password  
            }
         
            if ( $mode -eq "multi" ) {
                
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking nvidia-smi on mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
                } 
            } else {
                $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                Write-Host ""
                Write-Host "Checking nvidia-smi on mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
            }
            $changeUser = $false
          }

        3 { #Check nvidia-smi in docker 
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password 
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking nvidia-smi in Container mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Checking nvidia-smi in Container mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
            }
            $changeUser = $false
          }
        4 { #Check docker images
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Check for docker image on mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker images').Output
                } 
            } else { 
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Remove all docker image on mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker images').Output
            }
            $changeUser = $false
          }

         5 { #Check docker containers
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object {
                $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Check for docker container on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker ps').Output
               }
            } else {
                $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker ps').Output
            }
            $changeUser = $false
          }


        6 { #Remove all docker images
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Remove all docker image on mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Remove all docker image on mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
            }
            $changeUser = $false
          }

        7 { #Remove all docker containers
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object {
                $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
               }
            } else {
                $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
            }
            $changeUser = $false
          }

        8 { #Check IP-address

            ## Något fel här!
            {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }        
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking IP address for mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'ip ad').Output
                }
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Checking IP address for mlcomputer00$SingelComputer" -ForegroundColor DarkYellow;
                    (Invoke-SSHCommand -SSHSession $session -Command 'ip ad').Output 

            } 
            $changeUser = $false
          }
          9 { #Check for security update
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password          
            }
            
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'apt-get -s dist-upgrade |grep "^Inst" |grep -i securi ' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession 'apt-get -s dist-upgrade |grep "^Inst" |grep -i securi ' -Command $command ).Output
            }
            $changeUser = $false
          }

        10 { #Show full upgrade
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object {
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst"' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst"' ).Output
            }
            $changeUser = $false
          }

         11 { #Update security
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt-get install' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt-get install' ).Output
            }
            $changeUser = $false
          }

          12 { #Full upgrade
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt upgrade' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt upgrade' ).Output
            }
            $changeUser = $false
          }
        
        13 { #Send command
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            $command = Read-Host -Prompt "Command to execute "
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command $command ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command $command ).Output
            }
            $changeUser = $false
          }

        14 { #Connect with ssh
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Connect by SSH to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    ssh $user@mlcomputer00$_
                } 
            } else {
                    Write-Host ""
                    Write-Host "Connect by SSH to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    ssh $user@mlcomputer00$SingelComputer
            }
          }

        15 { # Computer to connect in singel mode
            
            $SingelComputer = Read-Host -Prompt "Select computer to connect with [1, 2, 3, 4, 5, 6, 7, 8]" 
           }


        16 { # Select $mode mode
             if ( $mode -eq "singel" ) { 
                $mode = "multi"
                $showMode = "singel"
             } else {
                $mode = "singel"
                $showMode = "multi"
             }
           }
        
        17 { #Change user
            $user = Read-Host -Prompt "User to use "
            $changeUser = $true
           }

        18 { #Change password
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
           }

        19 { #In RDP group
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'getent group | grep tsusers' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'getent group | grep tsusers' ).Output
            }
            $changeUser = $false
          }

        20 { #Logged in users
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'who -u' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'who -u' ).Output
            }
            $changeUser = $false
          }

        21 { #Kick out users

            
            if ( $changeUser ) {
                $password = Read-Host "Type password " -AsSecureString;
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            }
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    Write-Host ""
                    Write-Host "Warning this is a dangerous acction." -ForegroundColor DarkYellow
                    $input = Read-Host -Prompt "do you want to continue? yes/[no] "

                    if ( $input -eq "no" ) {
                        
                        exit(0)
                    }

                    (Invoke-SSHCommand -SSHSession $session -Command 'for i in $(who | awk {"print $1"}); do sudo pkill -KILL -u $i; done' ).Output
                } 
            } else {
                    $session = New-SSHSession -ComputerName mlcomputer00$SingelComputer -Credential $Credential
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$SingelComputer" -ForegroundColor DarkYellow; 
                    Write-Host ""
                    Write-Host "Warning this is a dangerous acction." -ForegroundColor DarkYellow
                    $input = Read-Host -Prompt "do you want to continue? yes/[no] "

                    if ( $input -eq "no" ) {
                        
                        exit(0)
                    }
                    (Invoke-SSHCommand -SSHSession $session -Command 'for i in $(who | awk {"print $1"}); do sudo pkill -KILL -u $i; done' ).Output
            }
            $changeUser = $false
            
          }

        22 { Exit }
    }
    Remove-SSHSession -SSHSession $session

    if ( !$SingelComputer -and $mode -eq "singel") { $SingelComputer = Read-Host -Prompt "Select computer to connect wirh [1, 2, 3, 4, 5, 6, 7, 8]" }
}