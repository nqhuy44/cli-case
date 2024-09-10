@Library('my-shared-library@v0.0.1') _
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
                }
            }
            steps
                script {
                    say.haha()
                }
        }
    }
}