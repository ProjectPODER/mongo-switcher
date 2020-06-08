#!/bin/sh 

# ORIGIN_POD=mongo-0
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins 
# ORIGIN_COLLECTION=test
# DESTINATION_COLLECTION=test

ENVIRONMENT=staging

source /var/lib/jenkins/allvars

PID=kubectl port-forward $ORIGIN_POD 27017:27017 &
echo `Running mongo dump`
echo `mongodump --uri=$MONGODB_URI -d $ORIGIN_DATABASE -c $ORIGIN_COLLECTION /tmp/dumps/$ORIGIN_COLLECTION`

mongodump --uri=$MONGODB_URI -d $ORIGIN_DATABASE -c $ORIGIN_COLLECTION /tmp/dumps/$ORIGIN_COLLECTION

kill $PID

ENVIRONMENT=production
source /var/lib/jenkins/allvars

PID=kubectl port-forward $ORIGIN_POD 27017:27017

echo "Running mongo restore"
echo "mongorestore --uri=$MONGO_URI -d $DESTINATION_DATABASE -c $ORIGIN_COLLECTION+"_new" /tmp/dumps/$ORIGIN_COLLECTION"

mongorestore --uri=$MONGO_URI -d $DESTINATION_DATABASE -c $ORIGIN_COLLECTION+"_new" /tmp/dumps/$ORIGIN_COLLECTION

echo "DROP old old destination collection"
echo "mongo $MONGO_URI -- db.$DESTINATION_COLLECTION_old.drop( )"

mongo $MONGO_URI -- `db.$DESTINATION_COLLECTION_old.drop( )`

echo "Rename current destination collection to old"
echo "mongo $MONGO_URI -- db.$DESTINATION_COLLECTION.renameCollection($DESTINATION_COLLECTION_old)"

mongo $MONGO_URI -- db.$DESTINATION_COLLECTION.renameCollection($DESTINATION_COLLECTION_old)` 

echo "Rename new origin collection to destination collection"
echo "mongo $MONGO_URI -- db.$ORIGIN_COLLECTION_new.renameCollection($DESTINATION_COLLECTION)"
mongo $MONGO_URI -- `db.$ORIGIN_COLLECTION_new.renameCollection($DESTINATION_COLLECTION)` 

kill $PID
