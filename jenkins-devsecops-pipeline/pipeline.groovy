pipeline {  
    agent any
    stages {
        stage('Git Pull'){
            steps {
                git url: 'https://github.com/we45/Vulnerable-Flask-App.git'
            }
        }   
        stage('Bandit - SAST'){
            steps {
                sh '''
                bandit -r -f html -o bandit-result.html app/ | true
                '''
                archiveArtifacts allowEmptyArchive: true, artifacts: '**/bandit-result.html', onlyIfSuccessful: true
                publishHTML (target: [
                  allowMissing: false,
                  alwaysLinkToLastBuild: false,
                  keepAll: true,
                  reportDir: '.',
                  reportFiles: 'bandit-result.html',
                  reportName: "Bandit Report"
                ])
            }
        }
        stage ('Safety - SCA') {
            steps {
                sh '''
                safety check --json > sca-report.json | true
                '''
                 
                archiveArtifacts allowEmptyArchive: true, artifacts: '**/sca-report.json', onlyIfSuccessful: true
                publishHTML (target: [
                  allowMissing: false,
                  alwaysLinkToLastBuild: false,
                  keepAll: true,
                  reportDir: '.',
                  reportFiles: 'sca-report.json',
                  reportName: "SCA Report"
                ])
            }
        }
        stage('Start App'){
            steps {
                sh 'docker run -d -p 5050:5050 abhaybhargav/vul_flask'
            }
        }
        stage('ZAP Baseline - DAST'){
            steps {
                sh '''
                docker run --network=host -u root -v $(pwd):/zap/wrk/:rw -d owasp/zap2docker-stable zap-baseline.py -t http://localhost:5050 -r zap.html
                sleep 90
                '''
                archiveArtifacts allowEmptyArchive: true, artifacts: '**/zap.html', onlyIfSuccessful: true
                publishHTML (target: [
                  allowMissing: false,
                  alwaysLinkToLastBuild: false,
                  keepAll: true,
                  reportDir: '.',
                  reportFiles: 'zap.html',
                  reportName: "DAST Report"
                ])
            }
        }
    }
    post {
        always {
            sh '''
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            '''
        }
    }
}