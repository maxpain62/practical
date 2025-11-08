podTemplate(
    yaml: """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: maven-build
spec:
  serviceAccountName: code-artifact-sa
  containers:
    - name: aws
      image: amazon/aws-cli
      command:
        - cat
      tty: true
      volumeMounts:
        - name: maven-cache
          mountPath: /root/.m2
    - name: maven
      image: maxpain62/maven-3.9:jdk12
      imagePullPolicy: Always
      command:
        - cat
      tty: true
      resources:
        limits:
          memory: "500Mi"
          cpu: "250m"
      volumeMounts:
        - name: maven-cache
          mountPath: /root/.m2
  volumes:
    - name: maven-cache
      emptyDir: {}
"""
) {

    node(POD_LABEL) {
        stage('Checkout Source') {
            git branch: 'master', url: 'https://github.com/maxpain62/hello-world.git'
            sh 'ls -l'
        }
        stage ('read token.txt file') {
          container('aws') {
                sh '''
                    aws codeartifact get-authorization-token --domain test --domain-owner 134448505602 --region ap-south-1 --query authorizationToken --output text > /root/.m2/token.txt
                '''
            }
        }
        stage ('build') {
          container ('maven') {
            sh '''
                  cp settings.xml /root/.m2/settings.xml
                  TOKEN=$(cat /root/.m2/token.txt)
                  sed "s|replace_me|$TOKEN|" settings-template.xml > /root/.m2/settings.xml
                  cat /root/.m2/settings.xml
                  sleep 5s
                  mvn clean deploy
               '''
          }
        }
    }
}
