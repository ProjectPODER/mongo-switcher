# Local and remote mongo collection switcher

For local renaming, run `node index.js` with parameters.

Parameters:
```
    { name: 'host', alias: 'h', type: String, defaultValue: 'localhost' },
    { name: 'port', alias: 'p', type: String, defaultValue: '27017' },
    { name: 'database', alias: 'd', type: String },
    { name: 'origin_collection', alias: 'oc', type: String },
    { name: 'destination_collection', alias: 'dc', type: String },
``

For remote renaming use `mongo_remote_switch.sh` with environment variables, this requiers allvars and can be run from jenkins.

Vars:
```
ORIGIN_POD=mongo-0
DESTINATION_POD=mongo-0
ORIGIN_DATABASE=poppins
DESTINATION_DATABASE=poppins 
ORIGIN_COLLECTION=records
DESTINATION_COLLECTION=records
```