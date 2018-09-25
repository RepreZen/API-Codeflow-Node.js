// jshint esversion:6, latedef: nofunc
const fs = require('fs');

class FakeDB {
	constructor(dataOrPath) {
		this.data = {};
		this.nextId = 1;
		if (dataOrPath) {
			this.load(dataOrPath);
		}
	}
	
	load(dataOrPath) {
		if (typeof(dataOrPath) === 'object') {
			doLoad(dataOrPath, this);
		} else if (typeof(dataOrPath) === 'string' && fs.existsSync(dataOrPath)) {
			doLoad(require(dataOrPath), this);
		}
	}

	select(type) {
		return doSelect(type, this.data);
	}
	
	get(type, id) {
		return (this.data[type] || {})[id]; 
	}
	
	insert(type, record) {
		if (this.data[type] === undefined) {
			this.data[type] = {};
		}
		let newRec = Object.assign({}, record, {id: this.nextId++});
		this.data[type][newRec.id] = newRec;
	}
	
	update(type, id, record) {
		let existing = this.data[type][id];
		if (existing) {
			this.data[type][id] = Object.assign(existing, record, {id});
		}
	}
	
	delete(type, id) {
		delete this.data[type][id];
	}
}

function doLoad(data, db) {
	for (let type of Object.keys(data)) {
		for (let rec of data[type]) {
			db.insert(type, rec);
		}
	}
}

function* doSelect(type, data) {
	for (let record of Object.values(data[type] || {})) {
		yield record;
	}
}

module.exports = FakeDB;
