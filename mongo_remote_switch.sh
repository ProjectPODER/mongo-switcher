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
# echo "Running mongo dump"
mongodump --uri=mongodb://$POPPINS_MONGO_HOST/$ORIGIN_DATABASE -c $ORIGIN_COLLECTION /tmp/dumps/$ORIGIN_COLLECTION

kill -9 $PID

ENVIRONMENT=production
source /var/lib/jenkins/allvars

kubectl port-forward $DESTINATION_POD 27017:27017 &
PID=$!

# echo "Running mongo restore"
mongorestore --uri=mongodb://$POPPINS_MONGO_HOST/$DESTINATION_DATABASE -c $ORIGIN_COLLECTION_new /tmp/dumps/$ORIGIN_COLLECTION

rm /tmp/dumps/$ORIGIN_COLLECTION

#echo "DROP old old destination collection"
mongo $POPPINS_MONGO_HOST --eval "db.${DESTINATION_COLLECTION}_old.drop()"

#echo "Rename current destination collection to old"
mongo $POPPINS_MONGO_HOST --eval "db.${DESTINATION_COLLECTION}.renameCollection(${DESTINATION_COLLECTION}_old)"

#echo "Rename new origin collection to destination collection"
mongo $POPPINS_MONGO_HOST --eval "db.${ORIGIN_COLLECTION}_new.renameCollection(${DESTINATION_COLLECTION})"

kill -9 $PID
