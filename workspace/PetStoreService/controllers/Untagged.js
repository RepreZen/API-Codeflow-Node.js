// jshint esversion:6, latedef:nofunc
"use strict";

const router = require('express').Router();
const UntaggedHandler = require('../handlers/Untagged');

router.get('/pets', (req, res) => {
	new UntaggedHandler(req.app.locals.db).findPets(req.query.tags, req.query.limit)
	.then((response) => handle(res, response))
	.catch((error) => res.status(error.code).json(error));
});

router.post('/pets', (req, res) => {
	new UntaggedHandler(req.app.locals.db).addPet(req.body)
	.then((response) => handle(res, response))
	.catch((error) => res.status(error.code).json(error));
});

router.get('/pets/:id', (req, res) => {
	new UntaggedHandler(req.app.locals.db).find_pet_by_id(req.params.id)
	.then((response) => handle(res, response))
	.catch((error) => res.status(error.code).json(error));
});

router.delete('/pets/:id', (req, res) => {
	new UntaggedHandler(req.app.locals.db).deletePet(req.params.id)
	.then((response) => handle(res, response))
	.catch((error) => res.status(error.code).json(error));
});

router.patch('/pets/:id', (req, res) => {
	new UntaggedHandler(req.app.locals.db).updatePet(req.params.id, req.body)
	.then((response) => handle(res, response))
	.catch((error) => res.status(error.code).json(error));
});

function handle(res, response) {
	if (response == null || typeof(response) !== "object" || !response.code) {
		response = {
			code: response === undefined ? 201 : 200,
			value: response
		};
	}
	res.status(response.code);
	if (response.value === undefined) {
		res.end() 
	} else {
		res.json(response.value);
	}
}

module.exports = router;
