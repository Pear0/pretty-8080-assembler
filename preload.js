"use strict";

function importScripts() {
}

var self = {};

self.addEventListener = function(name, func) {
    self.assemblerInterface = func;
};