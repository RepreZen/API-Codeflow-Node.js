package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi.OpenApiDocument
import com.modelsolv.reprezen.generators.api.template.AbstractDynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.OpenApi3

class AppGenerator extends AbstractDynamicGenerator<OpenApiDocument> {

	override generate(OpenApiDocument model) throws GenerationException {
		new AppFile(model, context).generate();
	}
}

class AppFile extends GeneratedFile {
	extension ModelHelper = new ModelHelper
	extension ModuleNameHelper = new ModuleNameHelper

	val private OpenApi3 model

	new(OpenApiDocument model, IGenTemplateContext context) {
		super(context, true)
		this.model = model.asKaizenOpenApi3;
	}

	override getContent() {
		'''
			// jshint esversion:6
			"use strict";
			const express = require('express');
			const swaggerUi = require('swagger-ui-express');
			const FakeDB = require('./lib/FakeDB');
			const Config = require('./lib/Config');
			const path = require('path');
			const {URL} = require('url');
			
			const app = express();
			
			let config = new Config();
			config.envSet("port", "APP_PORT", «param("port", 3000)»);
			config.envSet("host", "APP_HOST", «param("host", "localhost")»);
			config.envSet("overrideOrigin", "APP_OVERRIDE_ORIGIN", «param("overrideOrigin", true)»);
			config.envSet("pathPrefix", "APP_PATH_PREFIX", «param("pathPrefix","")»);
			config.envSet("suiPath", "APP_SWAGGER_UI_PATH", «param("swaggerUIPath", "/api")»);
			config.envSet("modelFile", "APP_MODEL_FILE", «param("modelFile", "swagger.yaml")»);
			config.envSet("publicFolder", "APP_PUBLIC_FOLDER", «param("publicFolder", "public")»);
			config.envSet("useFakeDB", "APP_USE_FAKE_DB", «param("useFakeDB", true)»);
			config.envSet("localDataFile", "APP_INITIAL_DATA_FILE", «param("dataFolder", null)»);
			app.locals.config = config;
			let conf = config.get();
			
			app.use(express.static(conf.publicFolder));
			
			app.use(conf.suiPath, swaggerUi.serve);
			app.use(conf.suiPath, swaggerUi.setup(null, {
				swaggerUrl: conf.modelFile,
				swaggerOptions: {
					// can't do this with a normal closure to make conf accessible, because
					// this ends up getting serialized into a generated .js file that's then
					// passed off to swagger-ui, and of course closure bindings don't make
					// it through. So we just evaluate the function definition as a string
					// here, with 'conf' in scope, and then pass the resulting function.
					// jshint evil: true
					requestInterceptor: eval(`(req) => {
							let url = new URL(req.url, "http://${conf.host}:${conf.port}");
							url.host = "${conf.host}:${conf.port}";
							req.url = url.href;
							return req;
						}`)
				}
			}));
			
			app.use(require('body-parser').json());
			app.use(require('body-parser').urlencoded({extended: false}));
			app.use(require('cookie-parser')());

			if (conf.useFakeDB) {
				let dataFile = conf.localDataFile ? path.resolve(__dirname, conf.localDataFile) : null; 
				app.locals.db = new FakeDB(dataFile);
			}
			
			let subapp = conf.pathPrefix ? express() : app;
			«FOR tag : model.operationsByTag.keySet»
				subapp.use(require('./controllers/«tag.moduleName»'));
			«ENDFOR»
			if (conf.pathPrefix) {
				app.use(conf.pathPrefix, subapp);
				subapp.locals = app.locals;
			}
			
			app.listen(conf.port, () => console.log(`Listening on port ${conf.port}`));
		'''
	}

	def param(String name, Object defaultValue) {
		var value = context.genTargetParameters.get(name) ?: defaultValue
		if (value !== null) {
			value = switch value {
				String: '''"«value»"'''
				Number:
					value
				Boolean:
					value
				default: '''"«value.toString»"'''
			}
		} else {
			value = "null"
		}
		value
	}

	override getRelativeFile() {
		"app.js"
	}
}
