@Library('jenkins-shared-lib-test@v0.0.5') _
pipeline {
    agent any
    stages {
        stage('Say Hello') {
            steps {
                script {
                    hello(name: 'Jenkins')
                }
            }
        }
        stage('Say Something') {
            steps {
                script {
                    say.nothing()
                    say.haha()
                    say.something('SOMETHING')
                }
            }
        }
    }
}
