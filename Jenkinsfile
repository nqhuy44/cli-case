@Library('jenkins-shared-lib-test@v0.0.2') _
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
            steps
                script {
                    say.something("New lib versions v0.0.2")
                }
        }
    }
}