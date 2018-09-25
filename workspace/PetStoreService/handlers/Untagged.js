// jshint esversion:6, latedef:nofunc
"use strict";
		
class UntaggedHandler {
	constructor(db) {
		this.db = db;
	}
	
	findPets(tags, limit) {
		// sample code
		try {
			tags = validate_tags(tags);
			limit = validate_limit(limit);
		} catch(error) {
			return Promise.reject(error);
		}
		let result = null; // compute desired result
		return Promise.resolve(result);
	}
	
	addPet(body) {
		// sample code
		try {
			body = validate_body(body);
		} catch(error) {
			return Promise.reject(error);
		}
		let result = null; // compute desired result
		return Promise.resolve(result);
	}
	
	find_pet_by_id(id) {
		// sample code
		try {
			id = validate_id(id);
		} catch(error) {
			return Promise.reject(error);
		}
		let result = null; // compute desired result
		return Promise.resolve(result);
	}
	
	deletePet(id) {
		// sample code
		try {
			id = validate_id(id);
		} catch(error) {
			return Promise.reject(error);
		}
		let result = null; // compute desired result
		return Promise.resolve(result);
	}
}				

function validate_tags(tags) {
	// check and/or alter parameter value as needed.
	// return value to be used in handler, or throw
	// an exception of the form {code, message} if
	// validation fails
	return tags;
}

function validate_limit(limit) {
	// check and/or alter parameter value as needed.
	// return value to be used in handler, or throw
	// an exception of the form {code, message} if
	// validation fails
	return limit;
}

function validate_body(body) {
	// check and/or alter parameter value as needed.
	// return value to be used in handler, or throw
	// an exception of the form {code, message} if
	// validation fails
	return body;
}

function validate_id_1(id_1) {
	// check and/or alter parameter value as needed.
	// return value to be used in handler, or throw
	// an exception of the form {code, message} if
	// validation fails
	return id_1;
}

function validate_id(id) {
	// check and/or alter parameter value as needed.
	// return value to be used in handler, or throw
	// an exception of the form {code, message} if
	// validation fails
	return id;
}

module.exports = UntaggedHandler;
