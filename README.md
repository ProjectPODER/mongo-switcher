# Local and remote mongo collection switcher

## Local
For local renaming, run `node index.js` with parameters.

Parameters:
```
    { name: 'host', alias: 'h', type: String, defaultValue: 'localhost' },
    { name: 'port', alias: 'p', type: String, defaultValue: '27017' },
    { name: 'database', alias: 'd', type: String },
    { name: 'origin_collection', alias: 'oc', type: String },
    { name: 'destination_collection', alias: 'dc', type: String },
```

## Remote
To upload data from staging to mongo run `mongo_dump_and_restore.sh`, this requires `allvars` and `env_vars` and can be run from jenkins (configured as cron every monday).

For remote renaming use `mongo_remote_switch.sh` with environment variables, this requires `allvars` and `env_vars` and can be run from jenkins.

## Poppins to staging
```
export DOCTL_TOKEN=[DIGITALOCEAN API TOKEN]
export SSH_KEYS=[KMAJI SSH KEY]
export DESTINATION_POD=mongo-0
export DESTINATION_CONTEXT=`$STAGING`

cp -a /var/lib/jenkins/allvars .


bash -ex ./mongo_dump_and_restore && ./mongo_remote_switch.sh 
```

## Stagin to prod
```
export DOCTL_TOKEN=[DIGITALOCEAN API TOKEN]
export SSH_KEYS=[KMAJI SSH KEY]
export DESTINATION_POD=bigmongo-0
export DESTINATION_CONTEXT=`$PRODUCTION`

cp -a /var/lib/jenkins/allvars .

bash -ex ./launch_droplet.sh
```
