# Zajęcia 06

## Pipeline

Poniżej znajduje się kod Jenkins Pipeline dla budowy i wdrażania Redis.

```groovy
pipeline {
    agent any
    environment {
        BUILDER_IMAGE = 'gcc:11'
        RUNTIME_IMAGE = 'ubuntu:22.04'
        REDIS_REPO = 'https://github.com/redis/redis.git'
        REDIS_BRANCH = '7.2'
        IMAGE_NAME = "redis-custom"
        CONTAINER_NAME = "redis-deploy"
    }
    stages {
        stage('Clone') {
            steps {
                git branch: env.REDIS_BRANCH, url: env.REDIS_REPO
            }
        }
        stage('Build & Test') {
            agent {
                docker {
                    image env.BUILDER_IMAGE
                    reuseNode true
                    args '--entrypoint="" -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'apt-get update && apt-get install -y tcl'
                sh 'make -j$(nproc)'
                sh 'make test'
                stash includes: 'src/redis-server,src/redis-cli,src/redis-sentinel', name: 'redis-binaries'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test/logs/*.log', fingerprint: true
                }
            }
        }
        stage('Build Runtime Image') {
            steps {
                unstash 'redis-binaries'
                writeFile file: 'Dockerfile.runtime', text: """
                    FROM ${env.RUNTIME_IMAGE}
                    RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*
                    COPY src/redis-server /usr/local/bin/
                    COPY src/redis-cli /usr/local/bin/
                    COPY redis.conf /usr/local/etc/redis/redis.conf
                    EXPOSE 6379
                    CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
                """
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -f Dockerfile.runtime ."
            }
        }
        stage('Deploy (Log Collection)') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} --network host ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }
        stage('Smoke Test') {
            steps {
                sleep 5
                sh "docker run --rm --network host alpine sh -c 'apk add --no-cache curl && curl -f http://localhost:6379' || true"
                sh "docker exec ${CONTAINER_NAME} redis-cli ping"
            }
        }
        stage('Publish') {
            steps {
                sh "mkdir -p redis-package/bin"
                sh "cp src/redis-server src/redis-cli src/redis-sentinel redis-package/bin/"
                sh "cp redis.conf redis-package/"
                sh "tar -czf redis-${BUILD_NUMBER}.tar.gz -C redis-package ."
                archiveArtifacts artifacts: "redis-${BUILD_NUMBER}.tar.gz", fingerprint: true
            }
        }
    }
    post {
        always {
            sh "docker logs ${CONTAINER_NAME} > redis-logs-${BUILD_NUMBER}.txt 2>&1"
            archiveArtifacts artifacts: "*.txt", fingerprint: true
            cleanWs()
        }
    }
}
```

## Dockerfile Tworzony w Pipeline



```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*
COPY src/redis-server /usr/local/bin/
COPY src/redis-cli /usr/local/bin/
COPY redis.conf /usr/local/etc/redis/redis.conf
EXPOSE 6379
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
```
## Sprawdzenie działania
![alt text](image-2.png)
![alt text](image-3.png)
![alt text](image-4.png)
![alt text](image-5.png)
![alt text](image-6.png)