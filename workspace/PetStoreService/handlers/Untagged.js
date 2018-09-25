// jshint esversion:6, latedef:nofunc
"use strict";
		
class UntaggedHandler {
	constructor(db) {
		this.db = db;
	}
	
	findPets(tags, limit) {
		try {
			tags = validate_tags(tags);
			limit = validate_limit(limit);
		} catch(error) {
			return Promise.reject(error);
		}
		let results = [];
		let tagFilter = (pet) => !tags || (pet.tag && tags.indexOf(pet.tag) >= 0);
		if (limit > 0) {
			for (let pet of this.db.select('Pet')) {
				if (tagFilter(pet)) {
					results.push(pet);
					if (results.length === limit) {
						break;
					}
				}
			}
		}
		return Promise.resolve(results);
	}
	
	addPet(pet) {
		try {
			pet = validate_pet(pet, true);
		} catch(error) {
			return Promise.reject(error);
		}
		// insert pet and get back pet with assigned id
		pet = this.db.insert('Pet', pet); 
		return Promise.resolve(pet);
	}
	
	find_pet_by_id(id) {
		try {
			id = validate_id(id);
		} catch(error) {
			return Promise.reject(error);
		}
		let pet = this.db.get('Pet', id);
		console.log(pet, id);
		if (pet) {
			return Promise.resolve(pet);
		} else {
			return Promise.reject({code: 404, message: "no such pet"});
		}
	}
	
	deletePet(id) {
		try {
			id = validate_id(id);
		} catch(error) {
			return Promise.reject(error);
		}
		this.db.remove('Pet', id);
		return Promise.resolve({code: 204});
	}
	
	updatePet(id, pet) {
		try {
			id = validate_id(id);
			pet = validate_pet(pet, false);
		} catch (error) {
			return Promise.reject(error);
		}
		let result = this.db.update('Pet', id, pet);
		if (result) {
			return Promise.resolve(result);
		} else {
			return Promise.reject({code: 404, message: "no such pet"});
		}
	}
}


function validate_tags(tags) {
	// style:form, explode: false => comma-separated values
	if (tags !== undefined) {
		// split on commas, trim tags, omit empty tags
		tags = tags.split(",").map(s=>s.trim()).filter(s=>!!s);
	}
	return tags;
}

function validate_limit(limit) {
	// if no limit provided, we set it to +INF
	if (limit === undefined) {
		limit = Number.POSITIVE_INFINITY;
	} else if (!/^[0-9]+$/.test(limit)) {
		throw {code: 400, message: "limit must be a non-negative integer"};
	} else {
		limit = Number.parseInt(limit);
	}
	return limit;
}

function validate_pet(pet, enforceRequired) {
	if (typeof(pet) !== "object") {
		throw {code: 400, message: "pet in request payload must be a JSON object"};
	} else if (enforceRequired && pet.name === undefined) {
		throw {code: 400, message: "pet name is required"};
	} else if (pet.name !== undefined && typeof(pet.name) !== "string") {
		throw {code: 400, message: "pet name must be a string"};
	} else if (pet.tag !== undefined && typeof(pet.tag) !== "string") {
		throw {code: 400, message: "pet tag must be a string"};
	}
	return pet;
}

function validate_id(id) {
	if (id === undefined) {
		throw {code: 400, message: "pet id is required"};
	} else if (!/^[0-9]+$/.test(id)) {
		throw {code: 400, message: "pet id must be a non-negative integer"};
	} else {
		id = Number.parseInt(id);
	}
	return id;
}

module.exports = UntaggedHandler;
