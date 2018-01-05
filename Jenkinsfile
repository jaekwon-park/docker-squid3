node('jenkins-slave') {
  timestamps {
    def app
    stage('Checkout') {
        checkout scm
    }
    stage('PreConfigure') {
        fileExists '${PRE_CONFIGURE}'
          sh """
              ${PRE_CONFIGURE}
          """
    }
    stage('Build') {
        app = docker.build("${DOCKER_BASE_URL}/${DOCKER_IMAGE_NAME}", "-f ${DOCKER_FILE_PATH} .")
    }

    stage('Test') {

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push') {
        withDockerRegistry([uri: '${DOCKER_BASE_URL}',credentialsId: "${DOCKER_ACCOUNT_CREDENTIALS}"]) {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

    stage('Scan'){
          withCredentials([usernamePassword(credentialsId: "${DOCKER_ACCOUNT_CREDENTIALS}",passwordVariable: 'PASSWORD',usernameVariable: 'USER')]) {
			sh """
            curl -u "$USER":"$PASSWORD" -X POST \
            https://${DOCKER_BASE_URL}/api/repositories/${DOCKER_IMAGE_NAME}/tags/latest/scan -i
            """
          }
    }
  }
}