async function createIndex(collection, index) {
    let result = null;
    try {
        result = await createRegularIndex(collection, index);
    }
    catch (err) {
        console.log(err);
        process.exit(1);
    }
    return result;
}

async function createRegularIndex(collection, index) {
    let options = {};
    if( index.hasOwnProperty('options') ) options = index.options;
    return collection.createIndex(index.index, options);
}

module.exports = createIndex;
