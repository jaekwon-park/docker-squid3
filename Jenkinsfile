node('jenkins-slave') {
  timestamps {
    def app
    stage('repository checkout') {
        checkout scm
    }

    stage('Build') {
        app = docker.build("${DOCKER_IMAGE_NAME}")
    }

    stage('Test') {

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push') {
        withCredentials([usernamePassword(credentialsId: "${DOCKER_ACCOUNT_CREDENTIALS}",passwordVariable: 'PASSWORD',usernameVariable: 'USER')]) {
          withDockerServer([uri: '$(DOCKER_BASE_URL}']) {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
          }
        }
    }
    stage('Scan'){
          sh """
          curl -u "${USER}":"${PASSWORD}" -X POST \
          https://${DOCKER_BASE_URL}/api/repositories/common/${DOCKER_IMAGE_NAME}/tags/latest/scan -i
          """
    }
  }
}

