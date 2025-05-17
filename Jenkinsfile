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
                    sh 'ls'
                    // Force rebuild to ensure Dockerfile changes are applied  
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
                        
                        // Verify container is running
                        sh "docker ps | grep flask_frontend_container"
                        
                        // Check exposed ports in container configuration
                        sh "echo 'Exposed ports:'"
                        sh "docker inspect -f '{{.Config.ExposedPorts}}' flask_frontend_container"
                        sh "echo 'Port bindings:'"
                        sh "docker inspect -f '{{.HostConfig.PortBindings}}' flask_frontend_container"
                        
                        // Give container time to start
                        sh "sleep 10"
                        
                        // Show container logs to verify startup
                        sh "echo 'Container logs:'"
                        sh "docker logs flask_frontend_container"
                        
                        // Try to check processes in container
                        sh "echo 'Processes in container:'"
                        sh "docker exec flask_frontend_container ps -ef || echo 'Could not check processes'"
                        
                        // Get container IP
                        def containerIP = sh(
                            script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' flask_frontend_container",
                            returnStdout: true
                        ).trim()
                        
                        echo "Container IP: ${containerIP}"
                        
                        // Test with both localhost and container IP to be thorough
                        echo "Testing container IP endpoint:"
                        sh "curl -v http://${containerIP}:${params.FRONTEND_PORT}/ || echo 'Failed to connect to container IP'"
                        
                        echo "Testing localhost endpoint:"
                        sh "curl -v http://localhost:${params.FRONTEND_PORT}/ || echo 'Failed to connect to localhost'"
                        
                        // Check HTTP status code
                        def statusCode = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' http://${containerIP}:${params.FRONTEND_PORT}/",
                            returnStdout: true
                        ).trim()
                        
                        echo "HTTP Status Code from container IP: ${statusCode}"
                        
                        // Accept 200 (OK) or 302 (Found/Redirect) as success
                        if (statusCode != "200" && statusCode != "302") {
                            error "HTTP request failed with status code: ${statusCode}"
                        } else {
                            echo "HTTP request successful with status code: ${statusCode}"
                        }
                    } catch (Exception e) {
                        echo "Test failed with error: ${e.message}"
                        
                        // Get container logs to help debug
                        sh "docker logs flask_frontend_container || true"
                        throw e
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