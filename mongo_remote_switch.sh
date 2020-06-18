# ORIGIN_POD=fast-poppins
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins
# ORIGIN_MONGODB_URI=mongodb://localhost:27017
# DESTINATION_MONGODB_URI=mongodb://user:pass@mongo-0.mongo:27017



function dump {
    kubectl exec -it $ORIGIN_POD -- mongodump --uri=$ORIGIN_MONGODB_URI -c=$1 --gzip --out=/data/db/switcher/
}

function restore {
    # echo "Running mongo restore"
    kubectl exec -it $DESTINATION_POD -- mongorestore --uri=$DESTINATION_MONGODB_URI -c="${1}_new" --drop -d=$DESTINATION_DATABASE --gzip --dir="/data/db/switcher/${ORIGIN_DATABASE}/${1}.bson.gz"

    #echo "DROP old old destination collection"
    kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_old.drop()"

    #echo "Rename current destination collection to old"
    kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}.renameCollection('${1}_old')"

    #echo "Rename new origin collection to destination collection"
    kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_new.renameCollection('${1}')"
}


ENVIRONMENT=staging

source /var/lib/jenkins/allvars

# echo "Running mongo dump"
dump "records" 
dump "persons"
dump "organizations"
dump "memberships"
dump "countries"

kubectl cp $ORIGIN_POD:/data/db/switcher/ /tmp/dumps/

kubectl config use-context $PRODUCTION

kubectl cp /tmp/dumps/ $DESTINATION_POD:/data/db/switcher/ 

restore "records"
restore "persons"
restore "organizations"
restore "memberships"
restore "countries"

rm -rf /tmp/dumps/
