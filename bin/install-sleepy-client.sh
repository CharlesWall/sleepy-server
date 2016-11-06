


read -p "Server Name: " -e serverName
if [ -n "$(grep sleepy-server:$1 ~/.ssh/config)" ]; then
    echo server $serverName already installed
    exit
fi

read -p "Host Name: " -e hostName
read -p "Identity File Path: " -e identityFilePath

read -p "AWS Profile Name: " -e awsProfileName
[ -n $awsProfileName ] && profileString="AWS_PROFILE=$awsProfileName"

read -p "User (ec2-user): " -e serverUser
[ -z $serverUser ] && serverUser=ec2-user


echo "\

##### sleepy-server:$serverName

Host $serverName
    HostName        $hostName
    User            $serverUser
    IdentityFile    \"$identityFilePath\"
    ProxyCommand    sh -c \"$profileString wake-instance %h && /usr/bin/nc %h %p\"

################################################################

" >> ~/.ssh/config

ssh $serverName "npm install -g sleepy-server && install-sleepy-server"
