Get MLcomputer up and running
1) Install Ubuntu server
2) Run installScript2.1.sh in sudo -i (need internet)
3) domainjoin (dont use domainjoin.sh)
4) run conf-sssd.sh

 
Push docker
1) Docker login

![image](https://github.com/user-attachments/assets/327a1c2e-c498-4eac-a494-70b4f51346de)

3) docker image tag <namn-image> <inloggning/repo:tag --> exempelvis: docker image tag ubuntulabb mindbraker2011/dt271:latest

![image](https://github.com/user-attachments/assets/4f585a91-7201-4ffd-9076-b3c3f9277fd6)

5) docker push <inloggning/repo:tag --> exempelvis: docker push mindbraker2011/dt271
![image](https://github.com/user-attachments/assets/5d4dcc34-d3a2-40d8-8440-8804bebab25a)
