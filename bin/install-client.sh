if [ -n "$(grep sleepy-server:$1 ~/.ssh/config)" ]; then
    echo server $1 already installed
    exit
fi

function outputUsage() {
    echo "install-client.sh <HostName> <IpAddress> <IdentityFilePath> <AwsProfileName>"
}

([ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]) && outputUsage

profileString=""
[ -n $4 ] && profileString="AWS_PROFILE=$4"

echo "\

##### sleepy-server:$1

Host $1
    HostName        $2
    User            ec2-user
    IdentityFile    \"$3\"
    ProxyCommand sh -c \"$profileString wake-instance %h && /usr/bin/nc %h %p\"

################################################################

" >> ~/.ssh/config

ssh $1 "npm install -g sleepy-server && install-sleepy-server"
