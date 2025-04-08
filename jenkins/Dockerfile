FROM jenkins/jenkins:lts
USER root
RUN apt update && apt install -y docker.io
RUN  apt-get install -y wget apt-transport-https gnupg lsb-release \
 && wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - \
 && echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list \
 && apt-get update && apt-get install -y trivy
USER jenkins

