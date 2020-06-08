#!/bin/sh 

# ORIGIN_POD=mongo-0
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins 
# ORIGIN_COLLECTION=test
# DESTINATION_COLLECTION=test

ENVIRONMENT=staging

source /var/lib/jenkins/allvars

kubectl port-forward $ORIGIN_POD 27017:27017 &
PID=$!
echo "Running mongo dump"
echo "mongodump --uri mongodb://${MONGODB_URI} -d ${ORIGIN_DATABASE} -c ${ORIGIN_COLLECTION} /tmp/dumps/${ORIGIN_COLLECTION}"

mongodump --uri mongodb://$MONGODB_URI -d $ORIGIN_DATABASE -c $ORIGIN_COLLECTION /tmp/dumps/$ORIGIN_COLLECTION

kill $PID

ENVIRONMENT=production
source /var/lib/jenkins/allvars

kubectl port-forward $ORIGIN_POD 27017:27017
PID=$!

echo "Running mongo restore"
echo "mongorestore --uri mongodb://${MONGODB_URI} -d ${DESTINATION_DATABASE} -c ${ORIGIN_COLLECTION}_new /tmp/dumps/${ORIGIN_COLLECTION}"

mongorestore --uri mongodb://$MONGODB_URI -d $DESTINATION_DATABASE -c $ORIGIN_COLLECTION_new /tmp/dumps/$ORIGIN_COLLECTION

echo "DROP old old destination collection"
echo "mongo $MONGODB_URI --eval db.${DESTINATION_COLLECTION}_old.drop()"

mongo $MONGODB_URI --eval "db.${DESTINATION_COLLECTION}_old.drop()"

echo "Rename current destination collection to old"
echo "mongo $MONGODB_URI --eval db.${DESTINATION_COLLECTION}.renameCollection(${DESTINATION_COLLECTION}_old)"

mongo $MONGODB_URI --eval "db.${DESTINATION_COLLECTION}.renameCollection(${DESTINATION_COLLECTION}_old)"

echo "Rename new origin collection to destination collection"
echo "mongo ${MONGODB_URI} -- db.${ORIGIN_COLLECTION}_new.renameCollection(${DESTINATION_COLLECTION})"
mongo $MONGODB_URI --eval "db.${ORIGIN_COLLECTION}_new.renameCollection(${DESTINATION_COLLECTION})"

kill $PID
