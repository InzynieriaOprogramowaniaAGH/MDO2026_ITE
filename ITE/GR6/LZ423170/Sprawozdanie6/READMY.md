# Zajęcia 06

## Pipeline


```groovy
pipeline {
    agent any
    environment {
        IMAGE_NAME = "redis-custom:${env.BUILD_ID}"
        CONTAINER = "redis-deploy"
    }
    stages {
        stage('Checkout & Build') {
            steps {
                git branch: 
                
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Deploy & Smoke Test') {
            steps {
                sh "docker rm -f ${CONTAINER} || true"
                sh "docker run -d --name ${CONTAINER} -p 6379:6379 ${IMAGE_NAME}"
                
                script {
                    sleep 5
                    sh "docker exec ${CONTAINER} redis-cli ping"
                }
            }
        }

        stage('Archive') {
            steps {
                
                sh "docker create --name extract ${IMAGE_NAME}"
                sh "docker export extract | gzip > redis-dist.tar.gz"
                sh "docker rm extract"
                archiveArtifacts 'redis-dist.tar.gz'
            }
        }
    }
    post {
        always {
            sh "docker logs ${CONTAINER} > redis.log 2>&1"
            archiveArtifacts '*.log'
            cleanWs()
        }
    }
}
```

## Dockerfile 



```dockerfile
FROM gcc:11 AS builder
RUN apt-get update && apt-get install -y tcl
WORKDIR /app
COPY . .
RUN make -j$(nproc) && make test


FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/src/redis-server /usr/local/bin/
COPY --from=builder /app/src/redis-cli /usr/local/bin/
COPY --from=builder /app/redis.conf /usr/local/etc/redis/redis.conf
EXPOSE 6379
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
```
## Sprawdzenie działania
![alt text](image-2.png)
![alt text](image-3.png)
![alt text](image-4.png)
![alt text](image-5.png)
![alt text](image-6.png)