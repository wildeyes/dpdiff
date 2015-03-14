shell = require 'shelljs/global'
program = require 'commander'
readline = require('readline')
rl = readline.createInterface input: process.stdin, output: process.stderr
glob = require 'glob'
ask = rl.question.bind rl
finishAsking = rl.close.bind rl
say = console.log.bind console

dropboxConflictedRegex = /.*\/(.*) \((.*) conflicted copy ([0-9\-]*)\)\.(.*)/

dpdiff = 
    findConflictedIn: (path) ->
        allFiles = glob.sync "#{path}/**/*", {dot: true, nodir: true}
        conflictedFiles = allFiles.filter (cfFile) ->
            parts = cfFile.match dropboxConflictedRegex
            if parts isnt null
                name = parts[0]
                extension = parts[parts.length - 1]
                match = allFiles.filter (file) ->
                    parts = file.match rxFile
                    file isnt cfFile and parts[0] is name and parts[1] is extension
        conflictedFiles.map (cfFile) -> 
            parts = cfFile.match dropboxConflictedRegex
            name = parts[0]
            extension = parts[parts.length - 1]
            path = cfFile.split '/'
            base = path.slice(path.length - 1)
            nonFile = "#{base}/#{name}.#{extension}"
            conflictedFile: cfFile, nonConflictedFile: nonFile

main = (file1, file2) ->
    conflictedFile = if rx.conflictedCopy.test(file1) then file1 else file2
    nonConflictedFile = if conflictedFile is file1 then file2 else file1
    exec ['diff', nonConflictedFile, conflictedFile].join(" ")
    ask "[0] Don't do anything.\n[1] Keep non-conflicted.\n[2] Keep conflicted.\nAnswer: ", (ans) ->
        i = parseInt ans
        switch i
            when 0 then say "Ok."
            when 1 then rm nonConflictedFile
            when 2 then rm conflictedFile
        finishAsking()

module.exports = dpdiff
