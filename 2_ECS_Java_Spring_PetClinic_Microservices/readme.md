## From Monolith To Microservices

In this example we take our monolithic application deployed on ECS and split it up into microservices.

![Reference architecture of microservices on EC2 Container Service](https://github.com/awslabs/amazon-ecs-java-microservices/blob/master/images/ecs-spring-microservice-containers.png)

## Why Microservices?

__Isolation of crashes:__ Even the best engineering organizations can and do have fatal crashes in production. In addition to following all the standard best practices for handling crashes gracefully, one approach that can limit the impact of such crashes is building microservices. Good microservice architecture means that if one micro piece of your service is crashing then only that part of your service will go down. The rest of your service can continue to work properly.

__Isolation for security:__ In a monolithic application if one feature of the application has a security breach, for example a vulnerability that allows remote code execution then you must assume that an attacker could have gained access to every other feature of the system as well. This can be dangerous if for example your avatar upload feature has a security issue which ends up compromising your database with user passwords. Separating out your features into micorservices using EC2 Container Service allows you to lock down access to AWS resources by giving each service its own IAM role. When microservice best practices are followed the result is that if an attacker compromises one service they only gain access to the resources of that service, and can't horizontally access other resources from other services without breaking into those services as well.

__Independent scaling:__ When features are broken out into microservices then the amount of infrastructure and number of instances of each microservice class can be scaled up and down independently. This makes it easier to measure the infrastructure cost of particular feature, identify features that may need to be optimized first, as well as keep performance reliable for other features if one particular feature is going out of control on its resource needs.

__Development velocity__: Microservices can enable a team to build faster by lowering the risk of development. In a monolith adding a new feature can potentially impact every other feature that the monolith contains. Developers must carefully consider the impact of any code they add, and ensure that they don't break anything. On the other hand a proper microservice architecture has new code for a new feature going into a new service. Developers can be confident that any code they write will actually not be able to impact the existing code at all unless they explictly write a connection between two microservices.

## Application Changes for Microservices

__Define microservice boundaries:__ Defining the boundaries for services is specific to your application's design, but for this REST API one fairly clear approach to breaking it up is to make one service for each of the top level classes of objects that the API serves:

```
/pet -> A service for all pet related REST paths
/vet -> A service for all vet related REST paths
/visits -> A service for all visit related REST paths
```

So each service will only serve one particular class of REST object, and nothing else. This will give us some significant advantages in our ability to independently monitor and independently scale each service.

__Stitching microservices together:__ Once we have created three separate microservices we need a way to stitch these separate services back together into one API that we can expose to clients. This is where Amazon Application Load Balancer (ALB) comes in. We can create rules on the ALB that direct requests that match a specific path to a specific service. The ALB looks like one API to clients and they don't need to even know that there are multiple microservices working together behind the scenes.

__Chipping away slowly:__ It is not always possible to fully break apart a monolithic service in one go as it is with this simple example. If our monolith was too complicated to break apart all at once we can still use ALB to redirect just a subset of the traffic from the monolithic service out to a microservice. The rest of the traffic would continue on to the monolith exactly as it did before.

Once we have verified this new microservice works we can remove the old code paths that are no longer being executed in the monolith. Whenever ready repeat the process by splitting another small portion of the code out into a new service. In this way even very complicated monoliths can be gradually broken apart in a safe manner that will not risk existing features.

## Prerequisites

You will need to have the latest version of the AWS CLI and maven installed before running the deployment script.  If you need help installing either of these components, please follow the links below:

[Installing the AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
[Installing Maven](https://maven.apache.org/install.html)

## Deployment

1. Run ```python setup.py -m setup -r <your region>```

## Test
 1. ```curl <your endpoint from output above>/<endpoint>```
 
supported endpoints are /, /pet, /vet, /owner, /visit

## Clean up

1.  Run ```python setup.py -m cleanup -r <your region>```
  
## Running on AWS Cloud9 Notes

General reference for using ECS: [The Elastic Container Service Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide)

In the setup.py script environment variables are used to configure Spring Boot to connect to the mysql db, e.g. the environment variable SPRING_DATASOURCE_URL. For reference on Spring auto configuration see [Deploying a Spring Boot Application on AWS Using AWS Elastic Beanstalk](https://aws.amazon.com/blogs/devops/deploying-a-spring-boot-application-on-aws-using-aws-elastic-beanstalk/) and the [Spring documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html).

This is also explained in the original blog article [Deploying Java Microservices on Amazon Elastic Container Service](https://aws.amazon.com/blogs/compute/deploying-java-microservices-on-amazon-ec2-container-service/).

The file \src\main\docker\spring-petclinic-rest-pet.yml is a docker compose file. For reference, see [Tutorial: Creating a Cluster with an EC2 Task Using the ECS CLI](Tutorial: Creating a Cluster with an EC2 Task Using the ECS CLI). I think the compose file / docker compose is NOT used in this project. The container for each service is configured in setup.py starting in line 446:
```PYTHON
        logger.info('Create Task Definition for: ' + service_list[service])
        containerDefinitions = [
            {
                'name': service,
                'image': repository_uri[service_list.keys().index(service)][service] + ':latest',
                'essential': True,
                'portMappings': [
                    {
                        'containerPort': int(service_list[service]),
                        'hostPort': 0
                    }
                ],
                'memory': 1024,
                'cpu': 1024,
                'environment': [
                    {
                        'name': 'SERVICE_ENDPOINT',
                        'value': elb_dns
                    },
                    {
                        'name': 'SPRING_PROFILES_ACTIVE',
                        'value': 'mysql'
                    },
                    {
                        'name': 'SPRING_DATASOURCE_URL',
                        'value': my_sql_options['dns_name']
                    },
                    {
                        'name': 'SPRING_DATASOURCE_USERNAME',
                        'value': my_sql_options['username']
                    },
                    {
                        'name': 'SPRING_DATASOURCE_PASSWORD',
                        'value': my_sql_options['password']
                    }
                ],
                'dockerLabels': {
                    'string': 'string'
                },
                'logConfiguration': {
                    'logDriver': 'awslogs',
                    'options': {
                        'awslogs-group': "ECSLogGroup-" + project_name,
                        'awslogs-region': region,
                        'awslogs-stream-prefix': project_name
                    }
                }
            }
        ]
        register_task_response = ecs_client.register_task_definition(
            family=service,
            taskRoleArn=role_arns['taskrolearn'],
            networkMode='bridge',
            containerDefinitions=containerDefinitions
        )
```
