# selar_take_home_test



Version control ---- Github
CI/CD----------------Jenkins, so there is a Jenkins fille for build step (workflow)
Building tool--------Maven
Artifactory Repository-----------Aws Ecr, a repo was created manually in the console
Ochestration tool ---------------EKS
Package manager -----------------Helm



THE JENKINS BUILD STEP (WORKFLOW) IN THE JENKINS FILE IS AS FOLLOWS:
Environment setup – Defines build variables like AWS account ID, region, image name, tag, and ECR repository URI.

Build with Maven – Runs mvn clean install inside the SampleWebApp folder to compile and package the Java app.

Test – Runs mvn test to execute the unit tests.

Login to AWS ECR – Uses stored AWS credentials to authenticate Docker with the AWS ECR registry.

Build Docker image – Builds a Docker image for the application and tags it with the build ID.

Push to ECR – Tags the local image with the full ECR URI and pushes it to AWS ECR.

Deploy to EKS

Updates local kubectl config to connect to the myAppp-eks-cluster.

Logs in to ECR again for pulling images.

Uses Helm to deploy or upgrade the app on the EKS cluster, setting the image repository and tag dynamically.

In short: Code → Build & Test → Dockerize → Push to ECR → Deploy to EKS via Helm.