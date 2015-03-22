shell = require 'shelljs/global'
_ = require 'lodash'
readline = require('readline')
glob = require 'glob'
fs = require 'fs'

rli = readline.createInterface input: process.stdin, output: process.stdout
ask = rli.question.bind rli
finishAsking = rli.close.bind rli
log = console.log.bind console
err = console.error.bind console
rxDPConflict = /(.*)\/(.*) \((.*) conflicted copy ([0-9\-]*)\)(.*)/
rxFile = /(.*)\/(.*)/


class File
    constructor: (@path) ->
        dpFileMatch = @path.match rxDPConflict
        if (@conflicted = dpFileMatch isnt null)
            [@path, @base, @name1, @from, @date, @name2] = dpFileMatch
            @name = @name1 + @name2
        else if not @conflicted
            regularFileMatch = @path.match rxFile
            [@path, @base, @name] = regularFileMatch
    matches: (otherFile) ->
        otherFile.name is @name and otherFile.base is @base
    toRegularFile: () -> path.join @base, @name
    #TODO? toConflictedFile: (from = @from, date = @date) -> path.join @base, @name, @ext
    toString: () -> @path

dpdiff =
    ask: (cfFile) ->
        if not fs.existsSync cfFile
            return err "#{cfFile} doesn't exist."
        exec ['diff', cfFile.toRegularFile(), cfFile].join(" ")
        ask "[0] Don't do anything.\n[1] Keep non-conflicted.\n[2] Keep conflicted.\nAnswer: ", (ans) ->
            i = parseInt ans
            switch i
                when 0 then say "Ok."
                when 1 then rm nonConflictedFile
                when 2 then rm conflictedFile
            finishAsking()

    findConflictedIn: (path) ->
        allFilePaths = glob.sync "#{path}/**/*", {dot: true, nodir: true}
        allFiles = allFilePaths.map (filePath) -> new File filePath
        [allConflicted, allNon] = _.partition allFiles, "conflicted", true
        allConflicted.filter (cfFile) -> (allNon.filter (regFile) -> cfFile.matches regFile).length > 0

module.exports = dpdiff
if require.main is module
    path = process.argv[2]
    conflicted = dpdiff.findConflictedIn path
    conflicted.forEach (cfFile) -> ask cfFile
