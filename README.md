# selar_take_home_test



Version control ---- Github
CI/CD----------------Jenkins, so there is a Jenkins fille for build step (workflow)
Building tool--------Maven
Image Repository-----------Aws Ecr, a repo was created manually in the console
Ochestration tool ---------------EKS
Package manager -----------------Helm



THE JENKINS BUILD STEP (WORKFLOW) IN THE JENKINS FILE FOR APP DEPLOYMENT IS AS FOLLOWS:
Environment setup – Defines build variables like AWS account ID, region, image name, tag, and ECR repository URI.

Build with Maven – Runs mvn clean install inside the SampleWebApp folder to compile and package the Java app.

Test – Runs mvn test to execute the unit tests.

Login to AWS ECR – Uses stored AWS credentials to authenticate Docker with the AWS ECR registry.

Build Docker image – Builds artifacts into images

Push to ECR –  pushes images to AWS ECR.

Deploy to EKS

Logs into ECR for pulling images.

Uses Helm to deploy or upgrade the app on the EKS cluster, setting the image repository and tag dynamically.

In short: Code → Build & Test → Dockerize → Push to ECR → Deploy to EKS via Helm.