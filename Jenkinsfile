pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_BUILD_IMAGE', defaultValue: 'flask_frontend_image', description: 'my flask frontend image name')
        string(name: 'FRONTEND_IMAGE_TAG',   defaultValue: 'latest',                 description: 'my frontend image tag')
        string(name: 'FRONTEND_PORT',        defaultValue: '4000',                  description: 'Port the flask app is running on')
    }
    
    stages {
        stage("Build our frontend Image") {
            steps {
                dir('AWS/project/python-three-tier-app/frontend') {
                    // Force rebuild without cache to ensure changes are applied
                    sh "docker build --no-cache -t ${params.FRONTEND_BUILD_IMAGE}:${params.FRONTEND_IMAGE_TAG} ."
                }
            }
        }
        
        stage("Test d'acceptance") {
            steps {
                script {
                    try {
                        // Start container with explicit port mapping
                        sh "docker run -d -p ${params.FRONTEND_PORT}:${params.FRONTEND_PORT} --name flask_frontend_container ${params.FRONTEND_BUILD_IMAGE}:${params.FRONTEND_IMAGE_TAG}"
                        
                        // Give container time to start
                        sh "sleep 5"
                        
                        // Show container logs to verify startup
                        sh "docker logs flask_frontend_container"
                        
                        // Get container IP
                        def containerIP = sh(
                            script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' flask_frontend_container",
                            returnStdout: true
                        ).trim()
                        
                        echo "Container IP: ${containerIP}"
                        
                        // Test a health endpoint to verify the service is up
                        sh "curl -v http://${containerIP}:${params.FRONTEND_PORT}/health"
                        
                        // Check HTTP status code
                        def statusCode = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' http://${containerIP}:${params.FRONTEND_PORT}/health",
                            returnStdout: true
                        ).trim()
                        
                        if (statusCode != "200") {
                            error "Health check failed with status code: ${statusCode}"
                        } else {
                            echo "Health check successful with status code: ${statusCode}"
                        }
                    } catch (Exception e) {
                        echo "Test failed with error: ${e.message}"
                        sh "docker logs flask_frontend_container || true"
                        throw e
                    } finally {
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