pipeline {
    agent any

    stages {
        stage('Build Builder Image') {
            steps {
                script {
                    sh 'docker build -f Dockerfile.build -t cpython-builder:${BUILD_NUMBER} -t cpython-builder:latest .'
                }
            }
        }
        
        stage('Test inside Container') {
            steps {
                script {
                    sh 'docker build -f Dockerfile.test -t cpython-tester:${BUILD_NUMBER} .'
                    sh 'docker rm -f cpython-test-run || true'
                    sh 'docker run --name cpython-test-run cpython-tester:${BUILD_NUMBER}'
                    sh 'docker logs cpython-test-run > test-results.log'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-results.log', fingerprint: true
                }
            }
        }

        stage('Build Deploy Image') {
            steps {
                script {
                    sh 'docker build -f Dockerfile.deploy -t cpython-deploy:3.13-build${BUILD_NUMBER} .'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh 'docker run --rm my-cpython-deploy:3.13-build${BUILD_NUMBER} python3 -c "print(\'Smoke test przeszedl pomyslnie!\')"'
                }
            }
        }
    }
}
