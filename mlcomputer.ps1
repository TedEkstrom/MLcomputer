
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
            [8] Change user
        "
        $input = Read-Host -Prompt "choose? "
    }
    
    switch ($input) {
        
        1 { 1..8 | ForEach-Object { Write-Host "Checking mlcomputer00$_"; Test-Connection -Count 1 mlcomputer00$_ }  }

        2 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Command nvidia-smi).Output
            } 
          }

        3 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command "docker run --rm --gpus all ubuntu nvidia-smi").Output
            } 
          }

        4 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rmi -f $(docker images -aq)').Output
            } 
          }

        5 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow;  
                (Invoke-SSHCommand -SSHSession $session -Command 'docker rm -vf $(docker ps -aq)').Output
            } 
          }


         
        6 { $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Commanddocker IP a ).Output
            } 
          }

        7 { 
            $command = Read-Host -Prompt "Command to execute: "
            $password = Read-Host "Type password: " -AsSecureString;
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $password
            $session = New-SSHSession -ComputerName mlcomputer00$_ -Credential $Credential
            1..8 | ForEach-Object { 
                Write-Host "############################################################################################"
                Write-Host ""
                Write-Host "Checking mlcomputer00$_" -ForegroundColor DarkYellow; 
                (Invoke-SSHCommand -SSHSession $session -Commanddocker $command ).Output
            } 
          }

        8 { $user = Read-Host -Prompt "User to use: "
          }
    }
}
