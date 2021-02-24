#When called autonomously, import variables. Else use env already set.
if [[ -z "${DESTINATION_MONGODB_URI}" ]]; then
    source allvars
    source env_vars
fi

echo "Switching data. Destructive action."

echo "DROP old old destination collection"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_old.drop()"

echo "Rename current destination collection to old"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}.renameCollection('${1}_old')"

echo "Rename new origin collection to destination collection"
kubectl exec -it $DESTINATION_POD -- mongo $DESTINATION_MONGODB_URI --eval "db.${1}_new.renameCollection('${1}')"
