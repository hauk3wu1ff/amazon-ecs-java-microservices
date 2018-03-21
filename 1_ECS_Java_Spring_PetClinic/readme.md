## Deploying in containers

In this example we take our java application and put it into a container for deployment on EC2 Container Service.

### Why containers?

__Improved Pipeline__: The container also allows an engineering organization to create a standard pipeline for the application lifecycle. For example:

1. Developers build and run container locally.
2. CI server runs the same container and executes integration tests against it to make sure it passes expectations.
3. Same container is shipped to a staging environment where its runtime behavior can be checked using load tests or manual QA.
4. Same container is finally shipped to production.

Being able to ship the exact same container through all four stages of the process makes delivering a high quality, reliable application considerably easier.

__No mutations to machines:__ When applications are deployed directly onto instances you run the risk of a bad deploy corrupting an instance configuration in a way that is hard to recover from. For example imagine a deployed application which requires some custom configurations in `/etc`. This can become a very fragile deploy as well as one that is hard to roll back if needed. However with a containerized application the container carries its own filesystem with its own `/etc` and any custom configuration changes that are part of this container will be sandboxed to that application's environment only. The underlying instance's configurations stay the same. In fact a container can't even make persistant filesystem changes without an explicit mounted volume which grants the container access to a limited area on the host instance.

## Why EC2 Container Service?

EC2 Container Service provides orchestration for your containers. It automates the process of launching containers across your fleet of instances according to rules your specify, then automates keeping track of where those containers are running so that you can use a load balancer to get traffic to them. It also has built in features to roll out deploys with zero downtime, gather metrics and logs from your containers, and auto scale the number of containers you are running based on metrics.

## Application Changes for Docker

To transform your existing Java Spring application into container you must compile, package, build a container image with the application package, and execution instruction. In addition, in order to run your container in the container cluster, it must be stored in a scaleable container registry. Amazon EC2 Container Registry (ECR) is a fully-managed  [Docker](https://aws.amazon.com/docker/) container registry that makes it easy for developers to store, manage, and deploy Docker container images. Amazon ECR is integrated with Amazon EC2 Container Service (ECS), simplifying your development to production workflow.

![alt text](https://github.com/awslabs/amazon-ecs-java-microservices/blob/master/images/ecs-spring-monolithic-containers.png)


1.  __Dependency Injection using Spring:__ We have modified the code to be separate interfaces into pet, owner, visit, etc as a first step towards microservice. We use Spring framework Repository annotation to inject the dependency in the specific path.  

2. __Create `Dockerfile`:__ Docker containers are created by using base images. An image can be basic, with nothing but the operating-system fundamentals, or it can consist of a sophisticated pre-built application stack ready for launch.

When building your images with docker, each action taken (i.e. a command executed such as apt-get install) forms a new layer on top of the previous one. These base images then can be used to create new containers. Dockerfile is a build script that contains these command use to create the container. At runtime Docker can build images automatically by reading the instructions from a Dockerfile.

It generally a best practice to store your Dockerfile in the same place as the application source code. The Dockerfile is kept together with the source code in your git repo and at any time your build pipeline is able to rebuild any container version you may need.

3. We use the [docker-spotify](https://github.com/spotify/docker-maven-plugin) plugin to run the maven build and create artifacts . The result is a container image that is a reliable unit of deployment. The container can be run locally, or run on a remote server. It will run the same in both places.

4. __Provision `AWS resources`:__ the setup.py provisions the AWS resources such as ECS, ECR, IAM Roles, ALB, RDS MySQL, AWS networking resources.

## Prerequisites

You will need to have the latest version of the AWS CLI and maven installed before running the deployment script.  If you need help installing either of these components, please follow the links below:

[Installing the AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
[Installing Maven](https://maven.apache.org/install.html)

## Deployment

1. Clone this repository - ```git clone <>```
2. Inspect the [Dockerfile](src/main/docker/Dockerfile)
```Dockerfile
FROM frolvlad/alpine-oraclejdk8:slim
VOLUME /tmp
ADD spring-petclinic-rest-1.7.jar app.jar
RUN sh -c 'touch /app.jar'
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]
```

This Dockerfile uses the Java Alpine as the base image. Copy the jar file from your local folder into the image. And set the container ENTRYPOINT to run executes the jar file at startup.

3. Inspect the [Maven pom file](./pom.xml)

  NOTE: In this pom.xml file we are using dockerfile maven plugin. This plugin configures the actual maven to build to package, compile your Java app, build container image, and push the image to a registry.

```xml
  <plugin>
      <groupId>com.spotify</groupId>
      <artifactId>docker-maven-plugin</artifactId>
      <version>0.4.13</version>
      <configuration>
          <imageName>${env.docker_registry_host}/${project.artifactId}</imageName>
          <dockerDirectory>src/main/docker</dockerDirectory>
          <useConfigFile>true</useConfigFile>
          <registryUrl>${env.docker_registry_host}</registryUrl>
          <!--dockerHost>https://${docker.registry.host}</dockerHost-->
          <resources>
              <resource>
                  <targetPath>/</targetPath>
                  <directory>${project.build.directory}</directory>
                  <include>${project.build.finalName}.jar</include>
              </resource>
          </resources>
          <forceTags>false</forceTags>
          <imageTags>
              <imageTag>${project.version}</imageTag>
          </imageTags>
      </configuration>
  </plugin>
```

2. Run ```python setup.py -m setup -r <your region>```

This setup script will create an ECR repository, load balancer, compile, build your project, upload the image to the ECR, deploy your infrastructure, and deploy the image into your infrastructure.

## Test

1. ```curl <your endpoint from output above>/<endpoint> ```

supported endpoints  are /, /pet, /vet, /owner, /visit

## Clean up

1. Run ```python setup.py -m cleanup -r <your region>```

## NextStep

[Lets break this app into microservices](https://github.com/awslabs/aws-java-microservice-refarch/tree/master/2_ECS_Java_Spring_PetClinic_Microservices)

## What I used on the Cloud9 EC2 Machine
```
devuser:~/environment/amazon-ecs-java-microservices/1_ECS_Java_Spring_PetClinic (master) $ history
    1  java -version
    2  mvn -version
    3  git clone https://github.com/hauk3wu1ff/amazon-ecs-java-microservices.git
    4  sudo yum install java-1.8.0-openjdk-devel
    5  sudo alternatives --config java
    6  sudo yum remove java-1.7.0-openjdk-devel
    7  sudo alternatives --config java
    8  java -version
    9  ls
   10  ls ~
   11  wget http://apache.spinellicreations.com/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
   12  tar xzvf apache-maven-3.5.3-bin.tar.gz
   13  echo $JAVA_HOME
   14  ls $JAVA_HOME\bin
   15  ls $JAVA_HOME/bin
   16  ls
   17  export PATH=~/environment/apache-maven-3.5.3/bin:$PATH
   18  rm apache-maven-3.5.3-bin.tar.gz 
   19  mvn --version
   20  docker info
   21  ls
   22  cd amazon-ecs-java-microservices/1_ECS_Java_Spring_PetClinic/
   23  mvn package
   24  ls -alF target/
   25  java -jar target/spring-petclinic-rest-1.7.jar
   26  python setup.py -m setup -r eu-west-1
   27  python -version
   28  python -m pip install --user boto3
   29  python setup.py -m setup -r eu-west-1
   30  python setup.py -m cleanup -r eu-west-1
   31  history
```