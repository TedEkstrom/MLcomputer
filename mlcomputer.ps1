
$user = WHOAMI /UPN

while (1) {
   
    $input = ""

    while (!$input) {
        Write-Host "

        current user: $user
        
            [1] Check if on.
            [2] Check nvidia-smi
            [3] Check nvidia-smi in docker
            [4] Remove all docker images
            [5] Remove all docker containers
            [6] Check IP-address
            [7] Send command
            [8] Connect with ssh
            [9] Change user
            [10] Exit
        "
        $input = Read-Host -Prompt "choose? "
        Write-Host ""
    }
    
    switch ($input) {
        
        1 { 1..8 | ForEach-Object { Write-Host "Checking mlcomputer00$_"; Test-Connection -Count 1 mlcomputer00$_ }  }

        2 { $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking nvidia-smi on mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
                Remove-SSHSession -SSHSession $session
            } 
          }

        3 { $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking nvidia-smi in Container mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
                Remove-SSHSession -SSHSession $session
            } 
          }

        4 { $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Remove all docker image on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
                Remove-SSHSession -SSHSession $session
            } 
          }

        5 { $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Remove all docker container on mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
                Remove-SSHSession -SSHSession $session
            } 
          }


         
        6 { $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking IP address for mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command 'docker IP a' ).Output
                Remove-SSHSession -SSHSession $session
            } 
          }

        7 { 
            $password = Read-Host "Type password " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            $command = Read-Host -Prompt "Command to execute "
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Send command to mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command $command ).Output
                Remove-SSHSession -SSHSession $session
            } 
          }

        8 { 
          
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Connect by SSH to mlcomputer00$_" -ForegroundColor DarkYellow; 
                ssh $user@mlcomputer00$_
            } 
          }

        9 { $user = Read-Host -Prompt "User to use "
          }

        10 { Exit }
    }
}
