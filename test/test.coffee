require 'shelljs/global'
should = require 'should'
path = require 'path'
fs = require 'fs'

dpdiff = require '../'


md = (dir) ->
    mkdir dir
    cd dir
fs.checkExists = (path) ->
    fs.openSync path, 'r'
    fs.closeSync()

describe 'dpdiff', ->
    conflicts = []
    before ->
        if test '-e', 'tmp' then rm '-r', 'tmp/*'
        md 'tmp'
        cp '../test/files/*', '.'
        appPath = path.resolve __dirname, '..', 'tmp'
        conflicts = dpdiff.findConflictedIn appPath
    it 'should list 4 conflicts', ->
        conflicts.length.should.equal(4)
    context 'when prompting us to pick between the conflicted and the non-conflicted', ->
        conflict = {}
        beforeEach ->
            conflict = conflicts.pop()
            dpdiff.ask conflict
        it 'should delete the conflicted file if prompt answered with [1]', ->
            process.stdin.write '1\n'
            (fs.existsSync conflict.path).should.be.true
            (fs.existsSync conflict.toRegularFile).should.be.false
        #it 'should delete the nonconflicted file if prompt answered with [2]', ->
            #process.stdin.write '2\n'
            #(-> fs.checkExists(conflict.conflictedFile)).should.not.throw()
            #(-> fs.checkExists(conflict.nonConflictedFile)).should.throw()
        #it 'shouldnt delete anything if prompt answered with [0]', ->
            #process.stdin.write '0\n'
            #(-> fs.checkExists(conflict.conflictedFile)).should.not.throw()
            #(-> fs.checkExists(conflict.nonConflictedFile)).should.throw()

