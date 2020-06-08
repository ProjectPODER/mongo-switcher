#/bin/sh 

# ORIGIN_POD=mongo-0
# DESTINATION_POD=mongo-0
# ORIGIN_DATABASE=poppins
# DESTINATION_DATABASE=poppins 
# ORIGIN_COLLECTION=records
# DESTINATION_COLLECTION=records

ENVIRONMENT=staging

source ../qqw-doks/kubernetes/extramodules/vars/allvars 

PID=kubectl port-forward $ORIGIN_POD 27017:27017 &
mongodump --uri=$MONGODB_URI -d ORIGIN_DATABASE -c $ORIGIN_COLLECTION /tmp/dumps/$ORIGIN_COLLECTION

kill $PID

ENVIRONMENT=production
source ../qqw-doks/kubernetes/extramodules/vars/allvars 

PID=kubectl port-forward $ORIGIN_POD 27017:27017

mongorestore --uri=$MONGO_URI -d $DESTINATION_DATABASE -c $ORIGIN_COLLECTION+"_new" /tmp/dumps/$ORIGIN_COLLECTION
mongo $MONGO_URI -- `db.$DESTINATION_COLLECTION_old.drop( )`
mongo $MONGO_URI -- `db.$DESTINATION_COLLECTION.renameCollection($DESTINATION_COLLECTION+"_old")` 
mongo $MONGO_URI -- `db.$ORIGIN_COLLECTION+"_new".renameCollection($DESTINATION_COLLECTION)` 
kill $PID
