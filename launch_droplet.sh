source env_vars

if [[ ! -v DOCTL_TOKEN ]]; then
    echo "DOCTL_TOKEN missing from env"
    exit 1
fi 
if [[ ! -v SSH_KEYS ]]; then
    echo "SSH_KEYS missing from env"
    exit 1
fi 


echo "Creating ${SCRIPT_LABEL}${YEAR} droplet ..."
RESPONSE=`doctl compute droplet create --region ${DROPLET_REGION} --size ${DROPLET_SIZE} --image ${DROPLET_IMAGE} --tag-name ${SCRIPT_LABEL} --wait --format PublicIPv4 --ssh-keys=\"${SSH_KEYS}\" ${SCRIPT_LABEL}`
IP="${RESPONSE/Public IPv4$'\n'/}"
sleep 20

echo "Configuring ${IP} ..."
ssh  -o "StrictHostKeyChecking no" root@${IP} "wget https://github.com/digitalocean/doctl/releases/download/v1.54.0/doctl-1.54.0-linux-amd64.tar.gz && tar xf ~/doctl-1.54.0-linux-amd64.tar.gz && sudo mv ~/doctl /usr/local/bin && mkdir -p ~/.config/doctl/ && echo \"access-token: ${DOCTL_TOKEN}\" > .config/doctl/config.yaml && doctl kubernetes cluster kubeconfig save k8s-production && doctl kubernetes cluster kubeconfig save k8s-1-14-4-do-0-sfo2-1563844775684"

echo "Copying script to ${IP} ..."
ssh  root@${IP} mkdir -p $SCRIPT_PATH_REMOTE
scp -rC $SCRIPT_PATH_LOCAL root@${IP}:$SCRIPT_PATH_REMOTE
scp -rC allvars root@${IP}:$SCRIPT_PATH_REMOTE
ssh  root@${IP} export DESTINATION_CONTEXT="${DESTINATION_CONTEXT}"

echo "Launching mongo_remote_switch in ${IP} ..."

ssh root@${IP} "cd $SCRIPT_PATH_REMOTE && bash -ex ./mongo_remote_switch.sh"

echo "Deleting ${IP}"
doctl compute droplet delete --force --tag-name ${SCRIPT_LABEL}
ssh-keygen -f "/var/lib/jenkins/.ssh/known_hosts" -R "${IP}"