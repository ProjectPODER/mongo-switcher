const MongoClient = require('mongodb').MongoClient;
const commandLineArgs = require('command-line-args');

const optionDefinitions = [
    { name: 'host', alias: 'h', type: String, defaultValue: 'localhost' },
    { name: 'port', alias: 'p', type: String, defaultValue: '27017' },
    { name: 'database', alias: 'd', type: String },
    { name: 'origin_collection', alias: 'oc', type: String },
    { name: 'destination_collection', alias: 'dc', type: String },
];

const args = commandLineArgs(optionDefinitions);
if(!args.origin_collection || !args.destination_collection) {
    console.log('ERROR: Please specify both origin and destination collections.');
    process.exit(1);
}

const db_uri = 'mongodb://' + args.host + ':' + args.port + '/' + args.database;
const client = new MongoClient(db_uri, {useUnifiedTopology: true});

client.connect(async function(err) {
    if(err) {
        console.error(err);
        process.exit(1);
    }

    console.log("Connected to mongo: "+args.db_uri);

    const db = client.db(args.database);

    //Drop the old old destination collection
    db.collection(args.destination_collection + '_old').drop();

    //Rename current destination collection to old destination collection
    db.collection(args.destination_collection).rename(args.destination_collection + '_old');

    //Rename origin collection to destination collection
    db.collection(args.origin_collection).rename(args.destination_collection);


    client.close();
    console.log('Done!');
    process.exit(0);
});
