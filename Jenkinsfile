pipeline{
    agent any
 
    tools{
        gradle 'Gradle'
        }
     
    stages {
        /*stage ('Software Composition Analysis'){
            steps {
              sh 'sudo dependency-check.sh --scan . -f XML -o .'
              sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Dependency Check Scan" -F "file=@dependency-check-report.xml;type=text/xml" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'  
            }    
        }*/
        stage('Static Code Analysis') {
            steps {
                    // SAST
                    sh './gradlew sonarqube \
  -Dsonar.projectKey=TX-DevSecOps \
  -Dsonar.host.url=http://192.168.6.238:9000 \
  -Dsonar.login=b228c4c2fb84af14b5787bd3856110686539a83b'

            sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=SonarQube Scan" -F "file=@sonar_report.html;type=text/html" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'                                        
            }
        }
        stage("Quality-Gate 1") {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }
        stage('Build') {
            steps {
                    // for build
                    sh './gradlew clean build --no-daemon'                                        
            }
        }
        stage('Performance Testing') {
            steps{
                 // for unit testing
                    junit(testResults: 'build/test-results/test/*.xml', allowEmptyResults : true, skipPublishingChecks: true)
            }
            post {
                success {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'build/reports/tests/test/', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
      }
    }

        stage ('Staging') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-staging', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'docker rm -f vulnerable-staging_VulnerableApp-jsp_1 vulnerable-staging_VulnerableApp-php_1 vulnerable-staging_VulnerableApp-base_1 vulnerable-staging_VulnerableApp-facade_1 && cd vulnerable-staging && docker-compose up -d', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'vulnerable-staging', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])            
            }
        }

        stage ('DAST') {
            steps {
                sh 'curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Acunetix Scan" -F "file=@scan_report_dast.xml;type=text/xml" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"'
            }
        } 

        stage ('Docker Scan') {
            steps {
               sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-staging', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'trivy image --format json -o scan_report1.json sasanlabs/owasp-vulnerableapp && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report1.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false" && trivy image --format json -o scan_report2.json sasanlabs/owasp-vulnerableapp-jsp && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report2.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false && trivy image --format json -o scan_report3.json sasanlabs/owasp-vulnerableapp-php && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report3.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false" && trivy image --format json -o scan_report4.json sasanlabs/owasp-vulnerableapp-facade && curl -X POST "http://192.168.6.241:8080/api/v2/import-scan/" -H  "accept: application/json" -H  "Authorization: Token c50c94737824e0bd561315ce8ee856849f5ba88f" -H  "Content-Type: multipart/form-data" -H  "X-CSRFToken: IoIe6juCf8QQxBkvAZR6aH0c0DvcZvsrcRlMvwNogRAsMfMfFBeTo9cC3yNMGdUp" -F "minimum_severity=Info" -F "active=true" -F "verified=true" -F "scan_type=Trivy Scan" -F "file=@scan_report4.json;type=application/json" -F "product_name=TX-DevSecOps" -F "engagement_name=DevSecOps-TX" -F "close_old_findings=false" -F "push_to_jira=false"', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
            }
        }

        
        stage ('Prod-Approval') {
            steps {
                input "Deploy to prod?"
            }
        }

        stage ('Production') {
            steps {
                sshPublisher(publishers: [sshPublisherDesc(configName: 'docker-production', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'cd vulnerable-prod && docker-compose up -d', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'vulnerable-prod', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])            
            }
        } 

        stage ('Infra Scan') {
            steps {
                sh 'ifconfig'
            }
        }
    }
}
