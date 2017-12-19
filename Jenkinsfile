/****************************** Environment variables ******************************/  
def JobName	= null						// variable to get jobname  
def Sonar_project_name = null 							// varibale passed as SonarQube parameter while building the application
def robot_result_folder = null 				// variable used to store Robot Framework test results
def server = Artifactory.server 'server1'	// Artifactory server instance declaration. 'server1' is the Server ID given to Artifactory server in Jenkins
def buildInfo = null 								// variable to store build info which is used by Artifactory
def rtMaven = Artifactory.newMavenBuild()	// creating an Artifactory Maven Build instance
def Reason = "JOB FAILED"					// variable to display the build failure reason
def lock_resource_name = null 					// variable for storing lock resource name

// Reading jar file name from pom.xml //
def getMavenBuildArtifactName() {
 pom = readMavenPom file: 'pom.xml'
 return "${pom.artifactId}-${pom.version}.${pom.packaging}"
}

// Email Notifications template when Build succeeds //
def notifySuccessful(){
emailext (
 attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
 <h1><FONT COLOR=Green>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1><h2 style=\'color:#e46c0a\'>GitHub Details</h2>
 <B>${BUILD_LOG_REGEX, regex="Started by ", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<br>
 ${BUILD_LOG_REGEX, regex="Checking out Revision", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</B>
 <p><!-- ${SCRIPT, template="unit_test_results.groovy"} --></p>
 <p><br><br>${SCRIPT, template="sonarqube_template.groovy"}<br></p>
 <p><br><br><br><br><br><br><br><h2 style=\'color:#e46c0a; font-family: Candara;\'>Artifactory Details</h2>
 <b style=\'font-family: Candara;\'>${BUILD_LOG_REGEX, regex="http://padlcicdggk4.sw.fortna.net:8088/artifactory/webapp/*", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<b></p>
 <p><br><br>${SCRIPT, template="robotframework_template_tmp.groovy"}</p>
 <p><br><br><br><br><br><br><br><h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br><h3>Please find below, the build logs and other files.</h3></p>
 </span>''', subject: '$DEFAULT_SUBJECT', to: 'sneha.kailasa@ggktech.com, yerriswamy.konanki@ggktech.com, sunil.boga@ggktech.com'
 )
}
 
// Email Notifications template when Build fails //
def notifyFailure(def Reason){
println "Failed Reason: ${Reason}"
emailext (
	attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
	<h1><FONT COLOR=red>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1>
  	<h1>${BUILD_LOG_REGEX, regex="Failed Reason:", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</h1>
	<p><h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br><h3>Please find below, the build logs and other files.</h3></p>
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'sneha.kailasa@ggktech.com, sunil.boga@ggktech.com'
	)
}

/****************************** Jenkinsfile execution starts here ******************************/
node {
	def content = readFile './.env'				// variable to store .env file contents
	Properties docker_properties = new Properties()	// creating an object for Properties class
	InputStream contents = new ByteArrayInputStream(content.getBytes());	// storing the contents
	docker_properties.load(contents)	
	contents = null
	try {
/****************************** Git Checkout Stage ******************************/
		stage ('Checkout') {
			Reason = "GIT Checkout Failed"
			checkout scm
		}	//Checkout SCM stage ends
      
// assigning the jarname to this variable aquired from pom.xml by below function //
		def jar_name = getMavenBuildArtifactName()

/****************************** Stage that creates lock variable and SonarQube variable ******************************/
		stage ('Reading Branch Varibles ')	{
		    Reason = " Reading Branch Varibles stage Failed"
            JobName = "${JOB_NAME}"
			if("${BRANCH_NAME}".startsWith('PR-'))
			{
                def index = JobName.indexOf("/");
				lock_resource_name = JobName.substring(0 , index)+"_"+"${CHANGE_TARGET}"
                Sonar_project_name = lock_resource_name + "PR"
			}
			else
			{
				 def index = JobName.indexOf("/");
				 lock_resource_name = JobName.substring(0 , index)+"_"+"${BRANCH_NAME}"
				 Sonar_project_name = lock_resource_name
			} 
		}	// Reading branch variable stage ends
	
/****************************** Building the Application and performing SonarQube analysis ******************************/	
		stage ('Maven Build') {
			Reason = "Maven Build Failed"
			rtMaven.deployer server: server, snapshotRepo: docker_properties.snapshot_repo, releaseRepo: docker_properties.release_repo			//Deploying artifacts to this repo //
			rtMaven.deployer.deployArtifacts = false		//this will not publish artifacts soon after build succeeds	//
			rtMaven.tool = 'maven'							//Defining maven tool //
			// Maven build starts here //
		//	withSonarQubeEnv {
				def mvn_version = tool 'maven'
				withEnv( ["PATH+MAVEN=${mvn_version}/bin",'Sonar_Project_Name=' + "${Sonar_project_name}"]  ) {
					buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true'// $SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.projectKey=${Sonar_Project_Name} -Dsonar.projectName=${Sonar_Project_Name}'
				}
			//}
		}	//Maven Build stage ends 

/****************************** Docker Compose and Robot Framework testing on container ******************************/
		stage ('Docker Deploy and RFW') {
			Reason = "Docker Deployment or Robot Framework Test cases Failed"
			lock(lock_resource_name) {
				// Docker Compose starts // 
				sh "jarfile_name=${jar_name} /usr/local/bin/docker-compose up -d"
				sh "sudo chmod 777 wait_for_robot.sh "
                sh './wait_for_robot.sh'
				robot_result_folder = docker_properties.robot_result_folder
				step([$class: 'RobotPublisher',
					outputPath: "/home/robot/${robot_result_folder}",
					passThreshold: 0,
					unstableThreshold: 0,
					otherFiles: ""])
				// If Robot Framework test case fails, then the build will be failed //	
				if("${currentBuild.result}" == "FAILURE")
					 {	
						 sh ''' ./clean_up.sh
                         echo "after cleanup"
						 exit 1'''
					 } 
				// If it is a GitHub PR job, then this part doesn't execute //					 
				if(!(JobName.contains('PR-')))
				{
					 // ***** Stage for Deploying artifacts to Artifactory ***** //				
					/*stage ('Artifacts Deployment'){		
						Reason = "Artifacts Deployment Failed"
						rtMaven.deployer.deployArtifacts buildInfo
						server.publishBuildInfo buildInfo
					}*/
					// ***** Stage for Publishing Docker images ***** //							
					stage ('Publish Docker Images'){
						Reason = "Publish Docker Images Failed"
						def cp_index = docker_properties.cp_image_name.indexOf(":");								
						def cpImageName = docker_properties.cp_image_name.substring(0 , cp_index)+":latest"
						def om_index = docker_properties.om_image_name.indexOf(":");
						def omImageName = docker_properties.om_image_name.substring(0 , om_index)+":latest"
						sh """
							docker tag ${docker_properties.om_image_name} ${docker_properties.Docker_Reg_Name}/${docker_properties.om_image_name}
							docker tag ${docker_properties.om_image_name} ${docker_properties.Docker_Reg_Name}/${omImageName}
							docker tag ${docker_properties.cp_image_name} ${docker_properties.Docker_Reg_Name}/${docker_properties.cp_image_name}
							docker tag ${docker_properties.cp_image_name} ${docker_properties.Docker_Reg_Name}/${cpImageName}
							"""
							docker.withRegistry("${docker_properties.Docker_Registry_URL}", "${docker_properties.Docker_Credentials}"){
								def customImage1 = docker.image("${docker_properties.Docker_Reg_Name}/${docker_properties.om_image_name}")
								customImage1.push()
								def customImage2 = docker.image("${docker_properties.Docker_Reg_Name}/${omImageName}")
								customImage2.push()
								def customImage3 = docker.image("${docker_properties.Docker_Reg_Name}/${docker_properties.cp_image_name}")
								customImage3.push()
								def customImage4 = docker.image("${docker_properties.Docker_Reg_Name}/${cpImageName}")
								customImage4.push()
							}
							sh """docker logout""" 
					
					}  //Docker publish stage ends here
				
					// ***** Stage for triggering CD pipeline ***** //				
					stage ('Starting QA job') {
					Reason = "Trriggering downStream Job Failed"
                    CD_Job_name = Sonar_project_name + "_QA"
		   			 	build job: CD_Job_name//, parameters: [[$class: 'StringParameterValue', name: 'var1', value: 'var1_value']]
					} 
				}     //if loop
				sh './clean_up.sh'	
			}   //lock			
		}		// Docker Deployment and RFW stage ends here //

/****************************** Stage for artifacts promotion ******************************/
/*		stage ('Build Promotions') {
			Reason = "Build Promotions Failed"
			def promotionConfig = [
				// Mandatory parameters
				'buildName'          : buildInfo.name,
				'buildNumber'        : buildInfo.number,
				'targetRepo'         : docker_properties.release_repo,
	 
				// Optional parameters
				'comment'            : 'PROMOTION SUCCESSFULLY COMPLETED',
				'sourceRepo'         : docker_properties.snapshot_repo,
				'status'             : 'Released',
				'includeDependencies': false,
				'copy'               : false,
				'failFast'           : true
			]
	 
			// Interactive promotion of Builds in Artifactory server from Jenkins UI //
			Artifactory.addInteractivePromotion server: server, promotionConfig: promotionConfig, displayName: "Promotions Time" //this need human interaction to promote
		}
	*/
/****************************** Stage for creating reports for SonarQube Analysis ******************************/
	/*	stage ('Reports creation') {
			Reason = "Reports creation Failed"
						sh """ echo ${Sonar_project_name} 
			curl "http://10.240.17.12:9000/sonar/api/resources?resource=${Sonar_project_name}&metrics=bugs,vulnerabilities,code_smells,duplicated_blocks" > output.json
			"""
		}
*/
/****************************** Stage for sending Email Notifications when Build succeeds ******************************/	
		stage ('Email Notifications') {
			notifySuccessful() 
		}
	}
	
catch(Exception e)
	{
		sh './clean_up.sh'
		currentBuild.result = "FAILURE"
		notifyFailure(Reason)
		sh 'exit 1'
	}
}
