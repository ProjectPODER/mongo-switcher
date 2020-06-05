const MongoClient = require('mongodb').MongoClient;
const commandLineArgs = require('command-line-args');
const parseIndexes = require('./lib/parser');
const createIndex = require('./lib/indexer');

const optionDefinitions = [
    { name: 'host', alias: 'h', type: String, defaultValue: 'localhost' },
    { name: 'port', alias: 'p', type: String, defaultValue: '27017' },
    { name: 'database', alias: 'd', type: String },
    { name: 'collection', alias: 'c', type: String },
    { name: 'file', alias: 'f', type: String }
];

const args = commandLineArgs(optionDefinitions);
if(!args.database || !args.collection) {
    console.log('ERROR: Please specify both a database and a collection.');
    process.exit(1);
}
if(!args.file) {
    console.log('ERROR: No index file specified.');
    process.exit(1);
}

const db_uri = 'mongodb://' + args.host + ':' + args.port + '/' + args.database;
const client = new MongoClient(db_uri, {useUnifiedTopology: true});

client.connect(async function(err) {
    if(err) {
        console.error(err);
        process.exit(1);
    }

    console.log("Connected to mongo.");

    const db = client.db(args.database);
    const collection = db.collection(args.collection);

    let indexes = parseIndexes(args.file);

    for(let i=0; i<indexes.length; i++) {
        console.log('Creating index ' + indexes[i].name);
        let result = await createIndex(collection, indexes[i]);
        console.log(result);
    }

    client.close();
    console.log('Done!');
    process.exit(0);
});
