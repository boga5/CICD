@Library('sample1') _    
def JobName	= null						    // variable to get jobname  
def Sonar_project_name = null 				// varibale passed as SonarQube parameter while building the application
def robot_result_folder = null 				// variable used to store Robot Framework test results
def server = null	    					// Artifactory server instance declaration. 'art1' is the Server ID given to Artifactory server in Jenkins  Artifactory.server 'server1'
def buildInfo = null 						// variable to store build info which is used by Artifactory
def rtMaven = Artifactory.newMavenBuild()	// creating an Artifactory Maven Build instance
def Reason = "JOB FAILED"					// variable to display the build failure reason
def VariableObject                          // object for class A
def lock_resource_name = null 
node {
	try
	{
		cleanWs()
		stage('Checkout') {
			Reason = "Checkout SCM stage Failed"
			checkout scm
			//checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/TestBoga']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/SnehaKailasa23/CICD.git']]]
		}
			
		def content = readFile './.env'    											// variable to store .env file contents
		Properties docker_properties = new Properties() 							// creating an object for Properties class
		InputStream contents = new ByteArrayInputStream(content.getBytes()); 		// storing the contents
		docker_properties.load(contents) 											
		contents = null
		stage('Reading Variables') {
			VariableObject = Reading_varibles()
		}
		
		server =  Artifactory.server docker_properties.ArtifactoryServerName
		println docker_properties.ArtifactoryServerName
		
		stage('Maven Build') {
			Reason = "Maven Build stage Failed"
			buildInfo = MavenBuild(rtMaven, server, docker_properties.snapshot_repo, docker_properties.release_repo, VariableObject.Sonar_project_name)	
		}
			
		def jar_name = getMavenArtifacts()
			
		 lock(VariableObject.lock_resource_name) {
			stage('Post Build') {
				stage('Docker Deplyoment and RFW testing'){
				    RFW(docker_properties.robot_result_folder, rtMaven, server, jar_name)
				}
				if(!(VariableObject.JobName.contains('PR-'))) {
					stage ('Artifacts Deployment') {
						Reason = "Artifacts Deployment stage failed"
						PushingArtifacts(rtMaven, buildInfo, server)
					}
					stage ('Publish Docker Images') {
						Reason = "Publishing Docker Images stage failed"
						PushingDockerImages(docker_properties.Docker_Reg_Name, docker_properties.om_image_name, docker_properties.cp_image_name, docker_properties.Docker_Registry_URL, docker_properties.Docker_Credentials, docker_properties.image_version, VariableObject.JobName)
					}
					stage ('Triggering CD Job') {
						Reason = "Starting QA job stage failed"
						TriggeringCDJob(VariableObject.Sonar_project_name, docker_properties.CDJob)
					}
					stage ('Build Promotions') {
						Reason = "Build Promotion stage failed"
						BuildPromotions(buildInfo, docker_properties.release_repo, docker_properties.snapshot_repo, server)
					}
				}    
				sh './clean_up.sh'
			}	
		}//lock part ends here  
		
		/*stage('Reports creation') {
			Reason = "Reports Creation Stage failed"
			SQReportsCreation(VariableObject.Sonar_project_name)
		} */
		stage('Email Notification'){
			Reason = "Triggering Email stage failed"
			notifySuccess(env.WORKSPACE)
		}
	}
	catch(Exception e)
	{
		sh './clean_up.sh'
		currentBuild.result = "FAILURE"
		Reason = notifyFailure(Reason)
		sh 'exit 1'
	}
}
