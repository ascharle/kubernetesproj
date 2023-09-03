# Coworking Space Service Extension
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Getting Started

Hello, I am a DevOps engineer responsible for deploying a set of APIs that make up the Coworking Space Service. This service enables users to request one-time tokens and administrators to authorize access to a coworking space. The APIs are designed following a microservice pattern, meaning they are split into distinct services that can be deployed and managed independently. My role involves building a pipeline to deploy an API that provides business analysts with basic analytics data on user activity in the coworking space service.

Project Dependencies
Workspace Environment Requirements
To complete this project, I ensured that my workspace had the following tools installed:

Python Environment: This is necessary to run Python 3.6+ applications and install Python dependencies via pip.
Docker CLI: This tool is essential for building and running Docker images locally.
kubectl: This command-line tool is required to run commands against a Kubernetes cluster.
helm: This tool is necessary to apply Helm Charts to a Kubernetes cluster.
GitHub: This platform is essential for pulling and cloning code.
Remote Resource Requirements
I utilized Amazon Web Services (AWS) for this project. The AWS resources I used include:

AWS CLI: This is the command-line interface tool to manage AWS services.
AWS CodeBuild: This service is used to build Docker images remotely.
AWS ECR: This is the Amazon Elastic Container Registry where Docker images are hosted.
Kubernetes Environment with AWS EKS: This is the Amazon Elastic Kubernetes Service used to run applications in k8s.
AWS CloudWatch: This service is used to monitor activity and logs in EKS.
Configure the Project
Configure a Database
I set up a Postgres database using a Helm Chart as follows:

Set up Bitnami Repo:

helm repo add bitnami https://charts.bitnami.com/bitnami
Install PostgreSQL Helm Chart:

helm install coworking-space-db bitnami/postgresql
This command sets up a Postgre deployment at coworking-space-db-postgresql.default.svc.cluster.local in the Kubernetes cluster. I verified it by running kubectl get svc.

Retrieve the password:

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default coworking-space-db-postgresql -o jsonpath="{.data.postgresql-password}" | base64 -d)
echo $POSTGRES_PASSWORD
Test Database Connection
The database is accessible within the cluster, so there might be issues connecting to it via the local environment. I connected to a pod that has access to the cluster as follows:

Connect Via a Pod:
bash
Copy code
kubectl exec -it <POD_NAME> bash
PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@coworking-space-db:5432/postgres -c <COMMAND_HERE>
Run Seed Files
I ran the seed files in the db/ directory to create the tables and populate them with data:

arduino
Copy code
kubectl port-forward --namespace default svc/coworking-space-db-postgresql 5432:5432 &
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
Running the Analytics Application Locally
In the analytics/ directory:

Install dependencies:
Copy code
pip install -r requirements.txt
Run the application:
bash
Copy code
DB_USERNAME=postgres DB_PASSWORD=$POSTGRES_PASSWORD python app.py
Verifying The Application
Generate a report for check-ins grouped by dates:
javascript
Copy code
curl <BASE_URL>/api/reports/daily_usage
Generate a report for check-ins grouped by users:
javascript
Copy code
curl <BASE_URL>/api/reports/user_visits
Deployment
I created a Docker image of the application and pushed it to AWS ECR. Then, I created Kubernetes deployment and service configuration files and applied them to the EKS cluster.

Build and push the Docker image:

css
Copy code
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker build -t coworking-space-analytics .
docker tag coworking-space-analytics:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/coworking-space-analytics:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/coworking-space-analytics:latest
Create Kubernetes deployment and service configuration files:

deployment.yaml:

yaml
Copy code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coworking-space-analytics
spec:
  replicas: 2
  selector:
    matchLabels:
      app: coworking-space-analytics
  template:
    metadata:
      labels:
        app: coworking-space-analytics
    spec:
      containers:
      - name: coworking-space-analytics
        image: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/coworking-space-analytics:latest
        ports:
        - containerPort: 5153
        env:
        - name: DB_USERNAME
          value: "postgres"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: coworking-space-db-postgresql
              key: postgresql-password
        - name: DB_HOST
          value: "coworking-space-db-postgresql.default.svc.cluster.local"
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: "postgres"
        - name: APP_PORT
          value: "5153"
service.yaml:

yaml
Copy code
apiVersion: v1
kind: Service
metadata:
  name: coworking-space-analytics
spec:
  selector:
    app: coworking-space-analytics
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5153
  type: LoadBalancer
Apply the configuration files to the EKS cluster:

Copy code
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
Verify the deployment and service:

arduino
Copy code
kubectl get deployments
kubectl get services
Conclusion
The Coworking Space Service is now deployed and running on AWS EKS. The analytics API can be accessed via the LoadBalancer URL, and it provides business analysts with basic analytics data on user activity in the coworking space service.

Stand-Out Suggestions

Specify Reasonable Memory and CPU Allocation in the Kubernetes Deployment Configuration
It is important to specify reasonable memory and CPU allocation in the Kubernetes deployment configuration to ensure the application runs efficiently. For this application, I recommend using the AWS t2.micro instance type as it provides a balance between compute power and cost.

Save on Costs
To save on costs, consider the following suggestions:

Use Spot Instances: AWS Spot Instances allow you to use spare EC2 computing capacity at a potentially



