node{ 
    stage('Git Pull'){
        git url: 'https://github.com/CSPF-Founder/JavaVulnerableLab.git'
    }   
    stage('Build package'){
        sh '''mvn package'''
    }
    stage('DepCheck - SCA'){
        dependencyCheckAnalyzer datadir: 'dependency-check-data', isFailOnErrorDisabled: false, hintsFile: '', includeCsvReports: false, includeHtmlReports: false, includeJsonReports: false, isAutoupdateDisabled: false, outdir: '', scanpath: '**/*.jar', skipOnScmChange: false, skipOnUpstreamChange: false, suppressionFile: '', zipExtensions: ''

        dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
    }
    stage ('FindSecBugs - SAST') {
 
        sh "/usr/bin/mvn -batch-mode -V -U -e findbugs:findbugs"
         
        def findbugs = scanForIssues tool: [$class: 'FindBugs'], pattern: '**/target/findbugsXml.xml'
        publishIssues issues:[findbugs]
    }
}