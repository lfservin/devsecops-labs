node{ 
    stage('Git Pull'){
        git url: 'https://github.com/we45/Vulnerable-Flask-App.git'
    }   
    stage('Bandit - SAST'){
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
    stage ('Safety - SCA') {
 
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
    stage('Build image') {
        app = docker.build("vulflask")
    }
    // stage('Run App') {
    //     def container = app.run("-p 5050:5050")
    // }
}