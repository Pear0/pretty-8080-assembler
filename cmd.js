"use strict";
var fs = require('fs');

function asmCall(msg, callback) {
    self.postMessage = callback;
    self.assemblerInterface({data: msg});
}

function paddedBinary(num) {
    var str = Number(num).toString(2);
    while (str.length % 8 !== 0) {
        str = '0' + str;
    }

    var str2 = '';
    for (var i = 0; i < str.length; i += 4) {
        str2 += str.substring(i, i + 4) + ' ';
    }

    return str2.trim();
}

// var sourceCode = ".org 0\nbegin:\nmvi a, 0\n jmp begin\n";

if (process.argv.length < 3) {
    console.log('Usage: node ' + process.argv[1] + ' <asm file>');
    return;
}

var sourceCode = fs.readFileSync(process.argv[2], 'utf-8');


asmCall({command: 'assemble', src: sourceCode}, function(result) {

    // console.log(JSON.stringify(result));

    var sourceLines = sourceCode.split('\n');

    var addressLineLookup = {};
    for (var j = 0; j < sourceLines.length; j++) {
        var line = sourceLines[j].trim();
        if (line.length === 0) {
            continue;
        }

        if (addressLineLookup.hasOwnProperty(result.gutter[j].addr)) {
            addressLineLookup[result.gutter[j].addr].push(line);
        } else {
            addressLineLookup[result.gutter[j].addr] = [line];
        }
    }

    if (result.errors.length > 0) {
        console.log('== ERROR ==');
        for (var i = 0; i < result.errors.length; i++) {
            if (result.errors[i] !== undefined) {
                console.log('Line ' + (i + 1) + ' ' + result.errors[i] + ': ' + sourceLines[i]);
            }
        }
        console.log('== ERROR ==');
        return;
    }

    asmCall({command: 'getbin'}, function(result) {
        var startAddr = result.org;

        // console.log(JSON.stringify(result));

        console.log('== Starting address: 0x' + Number(startAddr).toString(16) + ' ==');

        for (var i = 0; i < result.mem.length; i++) {
            var addr = startAddr + i;

            var line = paddedBinary( Math.floor(addr / 256)) + ' ' + paddedBinary(addr % 256);
            line += '    ' + paddedBinary(result.mem[i]);

            if (addressLineLookup.hasOwnProperty(i)) {
                line += '    ' + addressLineLookup[i].join(' / ');
            }

            console.log(line);

        }

    });

});

