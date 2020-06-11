# ORIGIN_POD=mongo-0
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins
# ORIGIN_COLLECTION=test
# DESTINATION_COLLECTION=test

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
mongodump --uri=$LOCAL_MONGODB_URI -c=$ORIGIN_COLLECTION --gzip --out=/tmp/dumps/

kill -9 $PID

ENVIRONMENT=production

source /var/lib/jenkins/allvars

kubectl port-forward $DESTINATION_POD 27017:27017 &
PID=$!

# echo "Running mongo restore"
mongorestore --uri=$LOCAL_MONGODB_URI -c="${ORIGIN_COLLECTION}_new" -d=poppins --gzip --dir="/tmp/dumps/poppins/${ORIGIN_COLLECTION}.bson.gz"

rm /tmp/dumps/$ORIGIN_COLLECTION

#echo "DROP old old destination collection"
mongo $LOCAL_MONGODB_URI --eval "db.${DESTINATION_COLLECTION}_old.drop()"

#echo "Rename current destination collection to old"
mongo $LOCAL_MONGODB_URI --eval "db.${DESTINATION_COLLECTION}.renameCollection(${DESTINATION_COLLECTION}_old)"

#echo "Rename new origin collection to destination collection"
mongo $LOCAL_MONGODB_URI --eval "db.${ORIGIN_COLLECTION}_new.renameCollection(${DESTINATION_COLLECTION})"

kill -9 $PID
