pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_BUILD_IMAGE', defaultValue: 'flask_frontend_image', description: 'my flask frontend image name')
        string(name: 'FRONTEND_IMAGE_TAG',   defaultValue: 'latest',                 description: 'my frontend image tag')
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
                        sh "sleep 60"
                        
                        // Get container IP
                        def containerIP = sh(
                            script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' flask_frontend_container",
                            returnStdout: true
                        ).trim()
                        
                        // Test with curl and check status code
                        def statusCode = sh(
                            script: "curl -I http://${containerIP}:4000",
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
    }
    
    post {
        failure {
            echo "Pipeline failed. Cleaning up resources..."
            sh "docker rm -f flask_frontend_container || true"
        }
    }
}