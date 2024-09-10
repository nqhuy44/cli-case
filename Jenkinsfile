@Library('jenkins-shared-lib-test@v0.0.1') _
pipeline {
    agent any
    stages {
        stage('Say Hello') {
            step {
                script {
                    hello(name: 'Jenkins')
                }
            }
        }
        stage('Say Something') {
            steps {
                step {
                    script {
                        say.nothing()
                    }
                }
                step {
                    script {
                        say.something()
                    }
                }
            }
        }
    }
}