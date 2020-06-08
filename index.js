const MongoClient = require('mongodb').MongoClient;
const commandLineArgs = require('command-line-args');

const optionDefinitions = [
    { name: 'host', alias: 'h', type: String, defaultValue: 'localhost' },
    { name: 'port', alias: 'p', type: String, defaultValue: '27017' },
    { name: 'database', alias: 'd', type: String },
    { name: 'origin_collection', alias: 'o', type: String },
    { name: 'target_collection', alias: 't', type: String },
];

const args = commandLineArgs(optionDefinitions);
if(!args.origin_collection || !args.target_collection) {
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

    console.log("Connected to mongo: " + db_uri);

    const db = client.db(args.database);

    try {
        //Drop the old old destination collection
        await db.collection(args.target_collection + '_old').drop();
    }
    catch(err) { console.log('Old database does not exist.'); }

    try {
        //Rename current destination collection to old destination collection
        await db.collection(args.target_collection).rename(args.target_collection + '_old');
    }
    catch(err) { console.log('Current database does not exist yet.'); }

    //Rename origin collection to destination collection
    await db.collection(args.origin_collection).rename(args.target_collection);


    client.close();
    console.log('Done!');
    process.exit(0);
});
