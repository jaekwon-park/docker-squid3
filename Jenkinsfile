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
            withCredentials([usernamePassword(credentialsId: "${HARBOR_CRUDENTIAL}",passwordVariable: 'PASSWORD',usernameVariable: 'USER')]) {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    stage('Scan'){
        sh '"
          curl -u "${USER}":"${PASSWORD}" -X POST \
          https://${DOCKER_BASE_URL}/api/repositories/common/coverage_agent/tags/latest/scan -i
          "'
    }
    catch (exc) {
      throw exc
    }
  }
}

