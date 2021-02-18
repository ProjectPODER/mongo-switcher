source allvars
source env_vars

echo "Switching data in production. Destructive action."

kubectl config use-context $DESTINATION_CONTEXT

echo "DROP old old destination collection"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_old.drop()"

echo "Rename current destination collection to old"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}.renameCollection('${1}_old')"

echo "Rename new origin collection to destination collection"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_new.renameCollection('${1}')"
