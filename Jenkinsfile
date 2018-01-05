@Library('sample1') _
node{ 
    Jenkins_File ( 
        ArtifactoryServerName: 'server1',
        snapshot_repo: 'fortna_snapshot', 
        release_repo: 'fortna_release', 
        Docker_Reg_Name: 'swamykonanki', 
        Docker_Registry_URL: 'https://index.docker.io/v1/', 
        Docker_Credentials: 'DockerCredentialsID',
        robot_result_folder: 'results',
        CDEnvironment: '_QA', 
        recipients: 'yerriswamy.konanki@ggktech.com, sunil.boga@ggktech.com, sneha.kailasa@ggktech.com'
    )
}
