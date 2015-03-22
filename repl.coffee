repl = require 'repl'

dpdiff = require './index.coffee'

repl.start
    prompt: "dpdiff # "
    useGlobal: true
    input: process.stdin
    output: process.stdout
