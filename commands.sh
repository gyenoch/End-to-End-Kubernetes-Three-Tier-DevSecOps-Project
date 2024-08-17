# Install Load Balancer
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=dev-medium-eks-cluster --approve

eksctl create iamserviceaccount --cluster=dev-medium-eks-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::091008253157:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-east-1
# eksctl create iamserviceaccount --cluster=dev-medium-eks-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::091008253157:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-east-1 --override-existing-serviceaccounts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=dev-medium-eks-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# Install Argocd
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
kubectl get all -n argocd
kubectl get svc -n argocd

# Expose Argocd to the load balancer
kubectl edit svc argocd-server -n argocd
# Change service type from ClusterIP to LoadBalancer

# Fetch password for Argocd
kubectl get secret -n argocd
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Setup Monitoring Tools Prometheus and Grafana
#Add the prometheus repo by using the below command
helm repo add stable https://charts.helm.sh/stable
helm repo update stable

# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
# Expose Prometheus
kubectl edit svc prometheus-server
# Change service type from ClusterIP to LoadBalancer

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana
# Expose Grafana
kubectl edit svc grafana
# Change service type from ClusterIP to LoadBalancer

# Fetch Grafana Password
kubectl get secret -n default
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo