node{
    stage('Git Pull'){
        git url: 'https://github.com/we45/Cut-The-Funds-NodeJS.git'
    }
    stage('Trufflehog'){
        sh '''
        docker run --rm -v $(pwd):/app trufflehog --max_depth 3 --json file:///app >> git-report.json | true
        '''
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/git-report.json', onlyIfSuccessful: true
    }
    stage('NpmAudit'){
        sh 'npm audit --json >> audit-report.json | true'
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/audit-report.json', onlyIfSuccessful: true
    }
    stage('NodeJSScan'){
        sh '''
        nodejsscan -d $PWD -o report
        '''
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/report.json', onlyIfSuccessful: true
    }
}