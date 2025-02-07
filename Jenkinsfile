pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = 'docker-creds'
        GIT_TOKEN = credentials('github-cred')
    }

    stages {
        stage('Installing Dependencies') {
            steps {
                bat 'npm install'
            }
        }
        stage('Scanning Dependencies') {
            steps {
                dependencyCheck additionalArguments: 'dependency-check --scan . --out target --disableYarnAudit --format ALL', odcInstallation: 'OWSAP-10'
            }
        }
        stage('Code Coverage'){
            steps {
                catchError(buildResult: 'SUCCESS', message: 'OOPS! WE MISSED COVERAGE!!!', stageResult: 'UNSTABLE') {
                    bat 'npm run coverage'
                }
            }
        }
        stage('SAST - SonarQube') {
            steps {
                withSonarQubeEnv('sonarserver') {
                    bat '''
                    sonar-scanner.bat \
                    -D"sonar.projectKey=pizza_app" \
                    -D"sonar.sources=."  
                    '''
                }
            }
        }

        stage('Building Docker Image'){
            steps {
                retry(2) {
                    bat 'docker build --no-cache -t sganesh3010/pizza-app:%GIT_COMMIT% -f Dockerfile .'
                }
            }
        }
        stage('Push Image to DockerHub') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-creds', url: "") {
                    bat 'docker push sganesh3010/pizza-app:%GIT_COMMIT%'
                }
            }
        }
        stage('Checkout Manifest & Update Image Tag') {
            steps {
                script {

                    bat '''

                    git checkout main

                    echo "Updating deployment.yaml with new image tag..."
                    powershell -Command "& { (Get-Content kubernetes\\deployment.yaml) -replace 'image: .*', 'image: sganesh3010/pizza-app:%GIT_COMMIT%' | Set-Content kubernetes\\deployment.yaml }"
                    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

                    echo "sganesh3010/pizza-app:%GIT_COMMIT%"

                    echo "File updated successfully!"
                    '''
                }
            }
        }
        stage('Commit and Push') {
            steps {
                script {
                    bat '''
                    git remote set-url origin https://%GIT_TOKEN%@github.com/Sganesh-30/Jenkins-CI-CD-Deployment.git

                    @echo off
                    cd kubernetes/

                    echo "Configuring Git..."
                    git config --global user.email "ganeshsg430@gmail.com"
                    git config --global user.name "Ganesh"

                    echo "Checking Git status..."
                    git status

                    echo "Staging changes..."
                    git add -A  && echo "Files staged successfully" || exit /b %ERRORLEVEL%

                    type deployment.yaml

                    echo "Committing changes..."
                    git diff --staged --quiet || git commit -m "Update image to sganesh3010/pizza-app:%GIT_COMMIT%" || exit /b %ERRORLEVEL%

                    echo "Pushing changes..."
                    git push -u origin main || exit /b %ERRORLEVEL%

                    echo "Changes pushed successfully!"
                    '''
                }
            }
        }

    }
}



