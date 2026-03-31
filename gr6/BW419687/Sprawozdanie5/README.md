Wszystkie poniższe czynności zostały wykonane na maszynie wirtualnej Ubuntu Server za pomocą SSH.

# Projekt uname
1. Utworzono nowy projekt poprzez New Item > Freestyle Job i dodano skrypt bash jako część builda w konfiguracji: ![](./1.png)
2. Zbudowano projekt: ![](./2.png)

# Projekt buildujący się tylko w parzyste godziny
1. Utworzono nowy projekt poprzez New Item > Freestyle Job i dodano skrypt bash jako część builda w konfiguracji: ![](./3.png)
2. Zbudowano w parzystą godzinę: ![](./4.png)
3. Zbudowano w nieparzystą godzinę: ![](./5.png)

# Obiekt typu pipeline
1. Utworzono nowy projekt poprzez New Item > Pipeline i napisano skrypt pipeline'a w konfiguracji:
```yaml
pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-builder-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: 'BW419687']],
                          userRemoteConfigs: [[url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git']]])
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    dir('Sprawozdanie5') {
                        def image = docker.build("${IMAGE_NAME}", ".")
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```