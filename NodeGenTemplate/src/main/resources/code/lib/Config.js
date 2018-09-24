// jshint esversion: 6
"use strict";

const process = require('process');

class Config {
	constructor() {
		this.config = {};
	}

	get(name) {
		if (name) {
			return this.config[name];
		} else {
			return this.config;
		}
	}
	
	set(name, value) {
		this.config[name] = value;
	}
	
	envSet(name, envName, value) {
		if (process.env[envName] === undefined) {
			this.config[name] = value;
		} else {
			this.config[name] = process.env[name];
		}
	}
}

module.exports = Config;