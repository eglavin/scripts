#!/usr/bin/env node
// @ts-check

import fs from "fs";

// Get arguments from command line input

const args = {
  "--path": "",
  "--output": "",
  "--size": "",
  "--above": "false",
};

for (const item of process.argv.slice(2)) {
  const [key, value] = item.split("=");
  if (key in args) {
    args[key] = value || "true";
  }
}

const {
  "--path": path,
  "--output": output,
  "--size": sizeString,
  "--above": above,
} = args;

const size = Number(sizeString) || 1.024;
const isAbove = above === "true";

// Check if the input file path is valid
if (!fs.existsSync(path)) {
  console.error("Invalid file path.");
  process.exit(1);
}

// Confirm output file does not exist
if (output && fs.existsSync(output)) {
  console.error("Output file already exists. Please provide a different name.");
  process.exit(1);
}

function stringify(output) {
  return JSON.stringify(output, null, 2);
}
function log(output) {
  console.log(output);
}

/**
 * @typedef {Object} FileContent
 * @property {string} Name
 * @property {string} Extension
 * @property {string} Path
 * @property {string} Size
 * @property {string} Width
 * @property {string} Height
 * @property {number} _fileSize
 */

/**  @type {Array<FileContent>} */
const fileData = JSON.parse(fs.readFileSync(path, "utf8"));

/** @type {Array<FileContent>} */
const filesInSizeRage = [];

for (const file of fileData) {
  const fileSizeNumber = Number(file.Size.split(" ")[0]);

  if (isAbove && fileSizeNumber >= size) {
    file._fileSize = fileSizeNumber;
    filesInSizeRage.push(file);
  } else if (!isAbove && fileSizeNumber < size) {
    file._fileSize = fileSizeNumber;
    filesInSizeRage.push(file);
  }
}

const content = filesInSizeRage.sort((a, z) => z._fileSize - a._fileSize);

log(stringify(content));
if (output) {
  fs.writeFileSync(output, stringify(filesInSizeRage));
}

log(`Total files: ${filesInSizeRage.length}`);
