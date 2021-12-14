export ORIGIN_POD=mongo-0
export DESTINATION_POD=mongo-0
export ORIGIN_DATABASE=poppins
export DESTINATION_DATABASE=poppins

MONGODB_URI="$(kubectl get secret mongodb-uri -o=jsonpath --template={.data.MONGODB_URI} | base64 --decode)"
MONGODB_CLUSTER_HOST="mongo-0.mongo.default.svc.cluster.local,mongo-1.mongo.default.svc.cluster.local"
REPSET="?replicaSet=MainRepSet"
LOCAL_MONGODB_URI=${MONGODB_URI/$MONGODB_CLUSTER_HOST/localhost}
export ORIGIN_MONGODB_URI=${LOCAL_MONGODB_URI/$REPSET/}
export DESTINATION_MONGODB_URI=ORIGIN_MONGODB_URI


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


kubectl cp /tmp/dumps/ $DESTINATION_POD:/data/db/switcher/

restore "records"
restore "persons"
restore "organizations"
restore "memberships"
restore "countries"

rm -rf /tmp/dumps/
