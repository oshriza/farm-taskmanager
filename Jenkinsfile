pipeline {
    // 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
    tools {
        maven 'maven-3.6.2'
    }
    options{
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
    }
    
    agent any

    environment {
        REPO = "${env.GIT_URL}"
        BRANCH_NAME = "${env.GIT_BRANCH}" // Release/1.1
        AWS_ACCOUNT_ID="644435390668"
        AWS_DEFAULT_REGION="us-east-2"
        IMAGE_TAG="latest"
        IMAGE_REPO_NAME_APP="oshri-portfolio-back"
        REPOSITORY_URI_APP="https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME_APP}"
        IMAGE_REPO_NAME_NGINX="oshri-portfolio-front"
        REPOSITORY_URI_NGINX="https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME_NGINX}"
        COMMIT_MSG=sh(script: 'git log -1 | grep "#test"' , returnStatus: true)
    }
    stages {
        stage ("checkout") {
            steps {
                echo 'checkout...'
                checkout scm
            }
        }
        stage ("build") {
            // when { expression {BRANCH_NAME ==~ /Release(.+)/ || BRANCH_NAME ==~ /feature(.+)/}}
            steps {
                echo 'BUILD...'
                sh "docker-compose build"
            }
        }

        stage ("test") {
            steps {
                echo 'TEST...'
                sh "docker-compose up -d"
                sh "sleep 10"
                sh "docker network connect jenkins_default front_container"
                sh "e2e/test.sh front:80"
            }
        }
        
        // stage ("publish") {
        //     when { expression {COMMIT_MSG == "0"}}
        //     steps {
        //         echo "Publish..."
        //         script {
        //             app=docker.build("${IMAGE_REPO_NAME_APP}")
        //             docker.withRegistry("${REPOSITORY_URI_APP}", "ecr:us-east-2:aws.credentials") {
        //                 app.push("${IMAGE_TAG}")
        //             }
        //             nginx=docker.build("${IMAGE_REPO_NAME_NGINX}", "-f ./Dockerfile.nginx .")
        //             docker.withRegistry("${REPOSITORY_URI_NGINX}", "ecr:us-east-2:aws.credentials") {
        //                 nginx.push("${IMAGE_TAG}")
        //             }
        //         }
        //     }
        // }
        // stage ("Deploy") {
        //     when { expression {COMMIT_MSG == "0"}}
        //     steps {
        //         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws.credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        //             echo "Deploy..."
        //             sh """
        //                 #!/bin/bash
        //                 cd terraform
        //                 terraform init

        //                 branch_name=${env.GIT_BRANCH}
        //                 branch_name=`echo \$branch_name | sed 's/\\//-/g'`
        //                 if [ ${env.GIT_BRANCH} = 'master' ]; then
        //                     terraform workspace select prod || terraform workspace new prod
        //                 else 
        //                     terraform workspace select \$branch_name || terraform workspace new \$branch_name
        //                 fi

        //                 terraform apply --auto-approve

        //                 echo 'E2E test...'
        //                 tf_output_ip=`terraform output -json ec2_instance_ip | jq -r '.[0]'`
        //                 sleep 10
        //                 ../e2e/test.sh \$tf_output_ip
                        
        //             """
        //         }

        //     }
        // }

    }
        post {
            always {
                echo "Deleting and clean workspace..."
                sh "docker-compose down"
                // sh "docker rm -f app"
                // sh "docker rm -f ted-nginx"
                sh "docker rmi -f ${IMAGE_REPO_NAME_NGINX}:${IMAGE_TAG}"
                sh "docker rmi -f ${IMAGE_REPO_NAME_APP}:${IMAGE_TAG}"
                cleanWs()
            }
            failure {
                emailext (
                    subject: "${currentBuild.result}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """<p>${currentBuild.result}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                            <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
                    recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']])
                // emailext body: '${DEFAULT_CONTENT}',
                //     subject: '${DEFAULT_SUBJECT}',
                //     to: '${DEFAULT_RECIPIENTS}',
                //     from: '${env.DEFAULT_FROM_EMAIL}'
            }
            success {
                echo "Success"
                // mail bcc: '', body: 'Success to deploy', cc: '', from: '', replyTo: '', subject: 'jenkins job', to: 'oshriza@gmail.com'
            } 
        }  

}