pipeline {
    // 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
    options{
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
        ansiColor('xterm')
    }
    
    agent any

    environment {
        REPO = "${env.GIT_URL}"
        BRANCH_NAME = "${env.GIT_BRANCH}" // Release/1.1
        AWS_ACCOUNT_ID="644435390668"
        AWS_DEFAULT_REGION="us-east-2"
        IMAGE_REPO_NAME_BACKEND="oshri-portfolio-back"
        REPOSITORY_URI_BACKEND="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME_BACKEND}"
        IMAGE_REPO_NAME_FRONTEND="oshri-portfolio-front"
        REPOSITORY_URI_FRONTEND="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME_FRONTEND}"
        COMMIT_MSG=sh(script: 'git log -1 | grep "#release"' , returnStatus: true)
    }
    stages {
        stage ("checkout") {
            steps {
                echo 'CHECKOUT...'
                checkout scm
            }
        }
        stage ("build") {
            steps {
                echo 'BUILD...'
                sh "docker-compose build"
            }
        }

        stage ("test") {
            steps {
                echo 'TEST...'
                sh "docker-compose up -d"
                sh "sleep 1"
                sh "docker network connect jenkins_default front_container"
                sh "e2e/test.sh front:80"
            }
        }

        stage('calc-tag') {
            when { expression {BRANCH_NAME == "main"} }
            steps {
                script {
                    sshagent(credentials: ['github.private.key']) {
                        sh "git fetch --all --tags"
                        IMAGE_TAG = sh(script: "git tag | sort -V | tail -1", returnStdout: true)
                        echo "Last image tag: ${IMAGE_TAG}"
                        if (IMAGE_TAG.isEmpty()) {
                            IMAGE_TAG = "1.0.0"
                        }
                        else { // 1.1.1
                            (major, minor, patch) = IMAGE_TAG.tokenize(".") // [1,1,1]
                            patch = patch.toInteger() + 1 // 2
                            echo "Increment to ${patch}"
                            IMAGE_TAG = "${major}.${minor}.${patch}" // 1.1.2
                            echo "the next tag for Release is: ${IMAGE_TAG}"
                        }
                    }
                }
            }
        } 
        
        stage ("publish") {
            // TODO: Parallel stage
            when { expression {BRANCH_NAME == "main"}}
            steps {
                echo "Publish to ECR..."
                script {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws.credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            // IMAGE_TAG = sh(script: "aws ecr describe-images --output json --repository-name oshri-portfolio-front --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[-1]' | jq . --raw-output | sort -r", returnStdout: true) 
                            sh "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.us-east-2.amazonaws.com"
                            sh "docker tag ${IMAGE_REPO_NAME_BACKEND}:latest ${REPOSITORY_URI_BACKEND}:${IMAGE_TAG}"
                            sh "docker push ${REPOSITORY_URI_BACKEND}:${IMAGE_TAG}"

                            sh "docker tag ${IMAGE_REPO_NAME_FRONTEND}:latest ${REPOSITORY_URI_FRONTEND}:${IMAGE_TAG}"
                            sh "docker push ${REPOSITORY_URI_FRONTEND}:${IMAGE_TAG}"
                        }
                }
            }
        }
        stage('tag-Release') {
            when { expression {BRANCH_NAME == "main"} }
            steps {
                echo "TAG RELEASE..."
                sshagent(credentials: ['github.private.key']) {
                    sh "git clean -f"
                    sh "git tag -a ${IMAGE_TAG} -m '${IMAGE_TAG}'"
                    sh "git push origin refs/tags/${IMAGE_TAG}"
                }
            }
        }

        stage('deploy') {
            when { expression { BRANCH_NAME == "main" } }
            steps {
                echo "DEPLOY..."
                    sshagent(credentials: ['github.private.key']) {
                        sh  """ #!/bin/bash
                            git clone git@github.com:oshriza/gitops-portfolio-taskmanager.git
                            cd gitops-portfolio-taskmanager/
                            yq -i '.appVersion = "${IMAGE_TAG}"' task-manager-app-layer3/Chart.yaml
                            git commit -am "Updated new release to version: ${IMAGE_TAG}"
                            git tag -a ${IMAGE_TAG} -m '${IMAGE_TAG}'
                            git push origin refs/tags/${IMAGE_TAG}
                            git push origin main
                            """

                    }
            }
        }

    }
    post {
        always {
            echo "Deleting and clean workspace..."
            sh "docker-compose down"
            script {
                if (BRANCH_NAME == "main") {
                    sh "docker rmi -f ${REPOSITORY_URI_FRONTEND}:${IMAGE_TAG}"
                    sh "docker rmi -f ${REPOSITORY_URI_BACKEND}:${IMAGE_TAG}"
                }
            }
            sh "docker rmi -f ${IMAGE_REPO_NAME_FRONTEND}:latest"
            sh "docker rmi -f ${IMAGE_REPO_NAME_BACKEND}:latest"
            cleanWs()
        }
        failure {
            echo "Failuree"
            // emailext (
            //     subject: "${currentBuild.result}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
            //     body: """<p>${currentBuild.result}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
            //             <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
            //     recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']])
        }
        success {
            echo "Success"
            // mail bcc: '', body: 'Success to deploy', cc: '', from: '', replyTo: '', subject: 'jenkins job', to: 'oshriza@gmail.com'
        } 
    }  

}