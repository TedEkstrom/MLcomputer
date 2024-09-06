Get MLcomputer up and running
1) Install Ubuntu server
2) Run installScript2.1.sh in sudo -i (need internet)
3) domainjoin (dont use domainjoin.sh)
4) run conf-sssd.sh

 
Push docker
1) Docker login

REPOSITORY             TAG       IMAGE ID       CREATED          SIZE
mindbraker2011/dt271   latest    4772f6c698d6   12 minutes ago   293MB
ubuntulabb             latest    4772f6c698d6   12 minutes ago   293MB

3) docker image tag <namn-image> <inloggning/repo:tag --> exempelvis: docker image tag ubuntulabb mindbraker2011/dt271:latest
4) docker push <inloggning/repo:tag --> exempelvis: docker push mindbraker2011/dt271
