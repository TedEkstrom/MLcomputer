
$user = WHOAMI /UPN
$mode = "multi" 
$showMode = "singel"
$SingelComputer = ""
$ShowSingelComputer = ""

while (1) {
   
    $input = ""

    if ( $mode -eq "singel" ) {
        $ShowSingelComputer = "[select: mlcomputer00$SingelComputer]"
    } else {
        $ShowSingelComputer = ""
    }

    while (!$input) {
        Write-Host "

        current user: $user, in $mode mode
        
            [1] Check if on
            [2] Check nvidia-smi
            [3] Check nvidia-smi in docker
            [4] Remove all docker images
            [5] Remove all docker containers
            [6] Check IP-address
            [7] Check for security update
            [8] Security update
            [9] Show full upgrade
            [10] Full upgrade
            [11] Send command
            [12] Connect with ssh
            [13] Change user
            [14] Select $showMode mode
            [15] Computer to connect in singel mode
            [16] Exit
            
        "
        $input = Read-Host -Prompt "choose? $ShowSingelComputer"
        Write-Host ""
    }

    if ( !$SingelComputer ) { $SingelComputer = Read-Host -Prompt "Select computer to connect wirh [1, 2, 3, 4, 5, 6, 7, 8]" }
    
    switch ($input) {
        
        1 { # Check if on
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; ; ping mlcomputer00$_ -n 1; Write-Host ""}  
            } else {
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; ; ping mlcomputer00$_ -n 1; Write-Host ""
            }
          }

        2 { # Check nvidia-smi
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            
            if ( $mode -eq "multi" ) {
                
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking nvidia-smi on mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
                } 
            } else {
                Write-Host ""
                Write-Host "Checking nvidia-smi on mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
            }
          }

        3 { #Check nvidia-smi in docker 
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking nvidia-smi in Container mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Checking nvidia-smi in Container mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
            }
          }

        4 { #Remove all docker images
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Remove all docker image on mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Remove all docker image on mlcomputer00$_" -ForegroundColor DarkYellow;  
                    (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
            }
          }

        5 { #Remove all docker containers
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object {
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
               }
            } else {
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
            }
          }

        6 { #Check IP-address
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Checking IP address for mlcomputer00$_" -ForegroundColor DarkYellow; 
                }
            } else {
                    Write-Host ""
                    Write-Host "Checking IP address for mlcomputer00$_" -ForegroundColor DarkYellow; 
            } 
          }
          7 { #Check for security update
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'apt-get -s dist-upgrade |grep "^Inst" |grep -i securi ' ).Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession 'apt-get -s dist-upgrade |grep "^Inst" |grep -i securi ' -Command $command ).Output
            }
          }

         8 { #Update security
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt-get install' ).Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst" | grep -i securi | awk -F " " {'print $2'} | xargs apt-get install' ).Output
            }
          }

          9 { #Show full upgrade
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            $command = Read-Host -Prompt "Command to execute "
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst"' ).Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt -s dist-upgrade | grep "^Inst"' ).Output
            }
          }

          10 { #Full upgrade
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            $command = Read-Host -Prompt "Command to execute "
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt upgrade' ).Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command 'sudo apt upgrade' ).Output
            }
          }
        
        11 { #Send command
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            $command = Read-Host -Prompt "Command to execute "
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command $command ).Output
                } 
            } else {
                    Write-Host ""
                    Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    (Invoke-SSHCommand -SSHSession $session -Command $command ).Output
            }
          }

        12 { #Connect with ssh
            if ( $mode -eq "multi" ) {
                1..8 | ForEach-Object { 
                    Write-Host "############################################################################################"
                    Write-Host ""
                    Write-Host "Connect by SSH to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    ssh $user@mlcomputer00$_
                } 
            } else {
                    Write-Host ""
                    Write-Host "Connect by SSH to mlcomputer00$_" -ForegroundColor DarkYellow; 
                    ssh $user@mlcomputer00$_
            }
          }

        13 { # Computer to connect in singel mode
            
            $SingelComputer = Read-Host -Prompt "Select computer to connect with [1, 2, 3, 4, 5, 6, 7, 8]" 
           }

        14 { # Select $mode mode
             if ( $mode -eq "singel" ) { 
                $mode = "multi"
                $showMode = "singel"
             } else {
                $mode = "singel"
                $showMode = "multi"
             }
           }
        
        15 { #Change user
            $user = Read-Host -Prompt "User to use "
           }

        16 { Exit }
    }
    Remove-SSHSession -SSHSession $session
}