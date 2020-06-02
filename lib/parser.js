const fs = require('fs');

function parseIndexes(pathToJSON) {
    let rawdata = fs.readFileSync(pathToJSON);
    let indexes = JSON.parse(rawdata);
    return indexes;
}

module.exports = parseIndexes;
