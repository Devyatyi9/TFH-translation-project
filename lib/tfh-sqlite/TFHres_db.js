const sqlite3 = require('sqlite3').verbose()
let db = new sqlite3.Database('./test/resources_prod.tfhres')
const fs = require('fs')


// Every JSON file  that contains dialogues is stored in ink_bytecode table in bytecode column so we query them
// hiberlite_id is unique row id, duh
sql = 'SELECT bytecode, hiberlite_id, shortname FROM ink_bytecode'
db.all(sql, (err, rows) => {
    if (err) {
        throw err
    }
    if (process.argv[2] === 'decode') {
        output = decodeFile(rows);
        saveOutput('./Test_pixel_overworld_dialog.json', output);
    }
    else if (process.argv[2] === 'encode') {
        encodeFile(rows)
    }
    else if (process.argv[2] === 'questions') {
        json = require('./temp.json')
        jsonFileToQuestionMarks(json)
        saveOutput('./temp.json', json)
    }

})

// Save file
saveOutput = (path, obj) => {
    fs.writeFile(path, JSON.stringify(obj, null, 4), 'utf8', (err) => {
        if (err) throw err; console.log('Saved!')
    })
}

ignoreSceneID = ['ari_outercave1-anutrainingsession_talktome_78', 'blanktest_start_1', 'prompt_test_doortdest1_119', 'prompt_test_door_test_120',
    'prompt_test_dummyrock_123', 'prompt_test_othertrigger_113', 'prompt_test_testinteract1_117', 'prompt_test_walktrigger_111', 'prompt_test_walk_talk_test_106',
    'testroomd_deer1_187', 'testroomd_defaultstart_168', 'testroomd_rockinteract1_169', 'testroomd_snake1_175', 'testroomd_snake2_186', 'testroomd_snakechest1_174',
    'testroomd_wof1_202', 'testroome_blackness_destination_179', 'trade_test_defaultstart_28', 'trade_test_madison_73', 'trade_test_thinking_statue_2_61',
    'trade_test_thinking_statue_3_62', 'trade_test_thinking_statue_56']


// Main decode function
function decodeFile(rows) {
    output = [];
    let skipped = 0;
    for (key in rows) {
        let sceneName = (rows[key].shortname)
        // database:/example.inkc
        // 'example.inkc'
        let start = /[^:\/]+$/
        // '.inkc'
        let end = /\.inkc/
        sceneName = sceneName.slice(sceneName.search(start), sceneName.search(end))
        if (ignoreSceneID.includes(sceneName)) {
            skipped++
            continue // continue to next key in rows
        }

        let dialogues = JSON.parse(rows[key].bytecode).root[2] // Root 2 contains dialogue related content
        output.push({ hiberlite_id: rows[key].hiberlite_id, scene: sceneName, text: {} }) // Creating header template so that decodeStuff has base to work with
        let elementNumber = parseInt(key) - skipped;
        decodeStuff(dialogues, output[elementNumber].text)
    }
    for (i = 0; i < output.length; i++) {
        if (Object.keys(output[i].text).length === 0) {
            output.splice(i, 1)
            i--
        }
    }
    return output;
}


ignoreKeys = ['on_create']
// Every string starts with a '^' and is NOT followed by ':'
var regExp = /^\^(?!:)/

// Recursive function that iterates over object copying its hierarchy and saving text from it
function decodeStuff(dialogues, outputText) {
    for (key in dialogues) {
        if (ignoreKeys.includes(key)) continue
        let val = dialogues[key]

        // Save string into output if we have one
        if (typeof val === 'string' && regExp.test(val)) {
            //Sometimes there are empty strings that only contain blank space so we skip them
            if (val != '^ ') outputText[key] = val.slice(1);
        }
        // Recursion time if we have something to iterate over
        else if (val && typeof val !== 'string') {
            outputText[key] = {};
            decodeStuff(dialogues[key], outputText[key])
        }
    }

    // Just clear junk and delete every empty branch of our output
    if (Object.keys(outputText) !== 0) {
        for (key of Object.keys(outputText)) {
            if (!outputText[key] || Object.keys(outputText[key]).length === 0) delete outputText[key]
        }
    }
}










// Main encode function
function encodeFile(rows) {
    const temp = require('./pixel_overworld_dialog_rus.json'); // Encoding happens from a temp.json file
    const stmt = db.prepare('UPDATE ink_bytecode SET bytecode = ? WHERE hiberlite_id = ?'); // sql again

    var json
    rowsOrdered = {};
    for (j = 0; j < rows.length; j++) {
        key = rows[j].hiberlite_id
        rowsOrdered[key] = rows[j]
    }
    for (let i in temp) {
        rowsKey = temp[i].hiberlite_id
        if (!rowsOrdered[rowsKey]) {
            console.log('Row ' + temp[i].hiberlite_id + ' not found!')
            continue
        }
        json = JSON.parse(rowsOrdered[rowsKey].bytecode)
        encodeStuff(json.root[2], temp[i].text)
        stmt.run(JSON.stringify(json), temp[i].hiberlite_id); // Overrides json stored in db with our encoded json
    }
    console.log('In process... (pause means done)')
}

// Recursive function that iterates over extracted json replacing each string in packed db json
// json is json to override, temp is our json
function encodeStuff(json, temp, adress = []) {
    if (!temp) return // i don't remember why i added this, hope this is important
    for (let key in temp) {
        let val = temp[key]

        // If we find string use its index to override original json
        if (typeof val === 'string') {
            if (json[key] !== '^' + val) json[key] = '^' + val
        }
        // Recursion time
        else if (val && typeof val !== 'string') {
            encodeStuff(json[key], val)
        }
    }
}








// Function for testing purposes that changes decoded json to contain only question marks. Works properly only on decoded jsons!
function jsonFileToQuestionMarks(json) {
    for (key in json) {
        let val = json[key]

        if (typeof val === 'string') {
            json[key] = val.replace(/\S/g, '?')
        }
        else if (val && typeof val !== 'string') {
            jsonFileToQuestionMarks(val)
        }
    }
    return json
}


