// index.js

const fs = require('fs');
const path = require('path');
const fileList = require('./files.json');
const { execSync } = require('child_process');

let errors = "";
const rootDir = execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();

const requiredFiles = path.join(rootDir, fileList.required);
const requiredFilesArray = fs.readFileSync(requiredFiles, 'utf8').toLowerCase().trim().split('\n');

const bannedFiles = path.join(rootDir, fileList.banned);
const bannedFilesArray = fs.readFileSync(bannedFiles, 'utf8').toLowerCase().trim().split('\n');

if (!fs.existsSync(requiredFiles) || requiredFilesArray.length === 0) {
    console.log("Required file/values not found " + requiredFiles);
}
if (!fs.existsSync(bannedFiles) || bannedFilesArray.length === 0) {
    console.log("Banned file/values not found " + bannedFiles);
}

// files added to commit that shouldn't be there
function checkBanned(bannedFiles) {

    const addedFilesArray = execSync('git diff --name-only --diff-filter=A origin/main', { encoding: 'utf8' }).toLowerCase().trim().split('\n');
    
    let bannedAddedFiles = addedFilesArray.filter(file => bannedFiles.includes(file));
    
    let errors = "";
    if (bannedAddedFiles.length > 0) {
        errors = "The following banned files were added: " + bannedAddedFiles.join(", ");
    }
    return errors;
}

// files removed from commit that shouldn't be
function checkRequired(requiredFiles) {

    const deletedFilesArray = execSync('git diff --name-only --diff-filter=D origin/main', { encoding: 'utf8' }).toLowerCase().trim().split('\n');
    
    let requiredDeletedFiles = deletedFilesArray.filter(file => requiredFiles.includes(file));
    
    let errors = "";
    if (requiredDeletedFiles.length > 0) {
        errors = "The following required files were deleted: " + requiredDeletedFiles.join(", ");
    }
    return errors;
}

requiredFilesResult = checkRequired(requiredFilesArray);
bannedFilesResult = checkBanned(bannedFilesArray);

if (requiredFilesResult || bannedFilesResult) {
    console.log("Required errors: " + requiredFilesResult);
    console.log("Banned errors: " + bannedFilesResult);
    process.exit(1);
} else {
    console.log("File check success");
    process.exit(0);
}