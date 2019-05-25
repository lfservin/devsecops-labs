node{ 
    stage('Git Pull'){
        git url: 'https://github.com/jobertabma/vulnerable.git'
    } 
    stage('SAST'){
        sh 'brakeman -o results.json | true'
        publishBrakeman 'results.json'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'brakeman-output.json', onlyIfSuccessful: true
    }
    stage('SCA'){
        sh '''
        bundle audit check >> audit-report.txt | true
        '''
        archiveArtifacts allowEmptyArchive: true, artifacts: 'audit-report.txt', onlyIfSuccessful: true
        publishHTML (target: [
          allowMissing: false,
          alwaysLinkToLastBuild: false,
          keepAll: true,
          reportDir: '.',
          reportFiles: 'audit-report.txt',
          reportName: "SCA Audit Report"
        ])
    }
    // stage('Depecheck'){
    //     dependencyCheckAnalyzer datadir: 'dependency-check-data', isFailOnErrorDisabled: false, hintsFile: '', includeCsvReports: false, includeHtmlReports: false, includeJsonReports: false, isAutoupdateDisabled: false, outdir: '', scanpath: '**/*.rb', skipOnScmChange: false, skipOnUpstreamChange: false, suppressionFile: '', zipExtensions: ''
    //     dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
    //     archiveArtifacts allowEmptyArchive: true, artifacts: '**/dependency-check-report.xml', onlyIfSuccessful: true
    // }
}