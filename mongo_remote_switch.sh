# ORIGIN_POD=mongo-0
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins

ENVIRONMENT=staging

source /var/lib/jenkins/allvars

MONGODB_URI="$(kubectl get secret mongodb-uri -o=jsonpath --template={.data.MONGODB_URI} | base64 --decode)"
MONGODB_CLUSTER_HOST="mongo-0.mongo.default.svc.cluster.local,mongo-1.mongo.default.svc.cluster.local"
REPSET="?replicaSet=MainRepSet"
LOCAL_MONGODB_URI=${MONGODB_URI/$MONGODB_CLUSTER_HOST/localhost}
LOCAL_MONGODB_URI=${LOCAL_MONGODB_URI/$REPSET/}

kubectl port-forward $ORIGIN_POD 27017:27017 &
PID=$!

# echo "Running mongo dump"
dump("records")
dump("persons")
dump("organizations")
dump("memberships")
dump("countries")

kill -9 $PID

ENVIRONMENT=production

source /var/lib/jenkins/allvars

kubectl port-forward $DESTINATION_POD 27017:27017 &
PID=$!

restore("records")
restore("persons")
restore("organizations")
restore("memberships")
restore("countries")


kill -9 $PID

function dump {
    mongodump --uri=$LOCAL_MONGODB_URI -c=$1 --gzip --out=/tmp/dumps/
}

function restore {
    # echo "Running mongo restore"
    mongorestore --uri=$LOCAL_MONGODB_URI -c="${1}_new" --drop -d=$DESTINATION_DATABASE --gzip --dir="/tmp/dumps/${ORIGIN_DATABASE}/${COLLECTION}.bson.gz"

    rm -rf /tmp/dumps/

    #echo "DROP old old destination collection"
    mongo $LOCAL_MONGODB_URI --eval "db.${1}_old.drop()"

    #echo "Rename current destination collection to old"
    mongo $LOCAL_MONGODB_URI --eval "db.${1}.renameCollection('${1}_old')"

    #echo "Rename new origin collection to destination collection"
    mongo $LOCAL_MONGODB_URI --eval "db.${1}_new.renameCollection('${1}')"
}