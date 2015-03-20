shell = require 'shelljs/global'
_ = require 'lodash'
readline = require('readline')
rl = readline.createInterface input: process.stdin, output: process.stderr
glob = require 'glob'
ask = rl.question.bind rl
finishAsking = rl.close.bind rl
say = console.log.bind console
log = say
rxDPConflict = /(.*)\/(.*) \((.*) conflicted copy ([0-9\-]*)\)\.(.*)/
rxFile = /(.*)\/(.*)\.(.*)/

class File
    constructor: (@path) ->
        dpFileMatch = @path.match rxDPConflict
        if (@conflicted = dpFileMatch isnt null)
            [@path, @base, @name, @from, @date, @ext] = dpFileMatch
        else if not @conflicted
            regularFileMatch = @path.match rxFile
            [@path, @base, @name, @ext] = regularFileMatch
    matches: (otherFile) -> 
        otherFile.name is @name and otherFile.ext is @ext and otherFile.base is @base
    toString: () -> @path

dpdiff =
    findConflictedIn: (path) ->
        allFilePaths = glob.sync "/Users/wie/Dropbox/code/github/dpdiff/#{path}/**/*", {dot: true, nodir: true}
        allFiles = allFilePaths.map (filePath) -> new File filePath
        [allConflicted, allNon] = _.partition allFiles, "conflicted", true
        allConflicted.filter (cfFile) -> allNon.filter((regFile) -> cfFile.matches regFile).length > 0
        
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
