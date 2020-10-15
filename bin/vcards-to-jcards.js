#!/usr/bin/env node

const boxen = require("boxen")
const chalk = require("chalk")
const fs = require("fs")
const ICAL = require("ical.js")
const yargs = require("yargs")

const options = yargs
  .usage("Usage: -f <filename> -o <output>")
  .option("f", {
    alias: "filename",
    describe: "VCard filename (.vcf)",
    type: "string",
    demandOption: true,
  })
  .option("o", {
    alias: "output",
    describe: "JCard filename (.json)",
    type: "string",
    demandOption: true,
  }).argv

const boxenOptions = {
  padding: 1,
  margin: 1,
  borderStyle: "round",
  borderColor: "green",
  backgroundColor: "#555555",
}

function run({ filename, output }) {
  // Reading
  console.log(boxen(chalk.white.bold(`Reading ${filename}`), boxenOptions))
  fs.readFile(filename, (err, data) => {
    if (err) throw err

    // Parsing
    console.log(boxen(chalk.white.bold(`Parsing ${filename}`), boxenOptions))
    const jcards = ICAL.parse(data.toString())

    // Writing
    console.log(boxen(chalk.white.bold(`Writing ${output}`), boxenOptions))
    const json = JSON.stringify(jcards, null, 2)
    fs.writeFile(output, json, (err) => {
      if (err) throw err

      // Success
      console.log(boxen(chalk.white.bold(`Success! ${jcards.length} JCards`), boxenOptions))
    })
  })
}

run(options)
