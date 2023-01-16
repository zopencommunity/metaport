node('linux')
{
  stage('Build') {
    build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/ZOSOpenTools/metaport.git'), string(name: 'PORT_DESCRIPTION', value: 'A set of utilities for z/OS Open Tools' )]
  }
}
