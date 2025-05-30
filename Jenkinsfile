pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_BUILD_IMAGE', defaultValue: 'flask_frontend_image', description: 'my flask frontend image name')
        string(name: 'FRONTEND_IMAGE_TAG',   defaultValue: 'latest',                 description: 'my frontend image tag')
        string(name: 'DOCKERHUB_REPO_NAME', defaultValue: 'devopspath', description: 'docker hub repository name')
    }
    
    stages {
        stage("Build our frontend Image") {
            steps {
                // switch into your frontend folder
                dir('AWS/project/python-three-tier-app/frontend') {
                    // list files (optional sanity check)
                    sh 'ls'  
                    // build with the name and tag from your parameters
                    sh """
                       docker build \
                         -t ${params.FRONTEND_BUILD_IMAGE}:${params.FRONTEND_IMAGE_TAG} \
                         .
                       """
                }
            }
        }
        
        stage("Test d'acceptance") {
            steps {
                script {
                    try {
                        // Start container
                        sh "docker run -d -p 4000:4000 --name flask_frontend_container ${params.FRONTEND_BUILD_IMAGE}:${params.FRONTEND_IMAGE_TAG}"
                        
                        // Give container time to start
                        sh "sleep 5"
                        
                        // Get container IP
                        def containerIP = sh(
                            script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' flask_frontend_container",
                            returnStdout: true
                        ).trim()
                        
                        // Test with curl and check status code
                       def statusCode = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' http://${containerIP}:4000",
                            returnStdout: true
                        ).trim()
                        
                        // Validate status code (200 is OK)
                        if (statusCode != "200") {
                            error "HTTP request failed with status code: ${statusCode}"
                        } else {
                            echo "HTTP request successful with status code: ${statusCode}"
                        }
                    } finally {
                        // Always clean up the container
                        sh "docker rm -f flask_frontend_container || true"
                    }
                }
            }
        }
         stage("Push to Docker Hub") {
        steps {
            // Use Jenkins credentials (create a 'dockerhub-credentials' with your Docker Hub username/password)
            withCredentials([usernamePassword(
                credentialsId: '550b2578-f31d-4312-adbd-f0714cb4d0fe',
                usernameVariable: 'DOCKERHUB_USER', 
                passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                sh "echo \"Tagging my image inother to push on docker hub\""
                sh "docker tag ${params.FRONTEND_BUILD_IMAGE}:${params.FRONTEND_IMAGE_TAG} ${DOCKERHUB_USER}/${params.DOCKERHUB_REPO_NAME}:latest"
                sh "echo \"Logging in to Docker Hub as ${DOCKERHUB_USER}\""
                sh "docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASS}"
                sh "sleep 10"
                sh "docker push ${DOCKERHUB_USER}/${params.DOCKERHUB_REPO_NAME}:latest"
            }
        }
    }
    }
    
    post {
        failure {
            echo "Pipeline failed. Cleaning up resources..."
            sh "docker rm -f flask_frontend_container || true"
        }
    }
}