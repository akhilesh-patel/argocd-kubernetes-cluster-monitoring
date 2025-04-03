kubectl apply -f ./cadvisor-service.yml
kubectl apply -f ./cadvisor-deployment.yml

kubectl apply -f ./Grafana.yml 

kubectl apply -f ./jenkins.yml

kubectl apply -f ./node-exportor.yml

kubectl apply -f ./prometheus-service.yml
kubectl apply -f ./prometheus-deployment.yml
kubectl apply -f ./prometheus-configmap.yml

kubectl apply -f ./sonarqube-postgress.yml
kubectl apply -f ./SonarQube-deployment.yml
