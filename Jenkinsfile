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
    }
}
