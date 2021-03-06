package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi.OpenApiDocument
import com.modelsolv.reprezen.generators.api.template.AbstractDynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.Operation
import com.reprezen.kaizen.oasparser.model3.Parameter
import com.reprezen.kaizen.oasparser.model3.RequestBody
import java.util.List

class ControllersGenerator extends AbstractDynamicGenerator<OpenApiDocument> {
	extension ModelHelper = new ModelHelper

	override generate(OpenApiDocument model) throws GenerationException {
		for (entry: model.asKaizenOpenApi3.operationsByTag.entrySet) {
			new ControllersFile(context, entry.key, entry.value).generate			
		}
	}
}

class ControllersFile extends GeneratedFile {
	extension ModelHelper = new ModelHelper
	extension ModuleNameHelper = new ModuleNameHelper
	extension MethodNameHelper = new MethodNameHelper
	extension ParamsHelper paramsHelper = new ParamsHelper
	
	val List<Operation> operations
	val String tag
	val String name
	

	new(IGenTemplateContext context, String tag, List<Operation> operations) {
		super(context, true)
		this.tag = tag
		this.name = tag.moduleName
		this.operations = operations
	}

	override getContent() {
		'''
			// jshint esversion:6, latedef:nofunc
			"use strict";
			
			const router = require('express').Router();
			const «name»Handler = require('../handlers/«name»');
			
			«FOR op : operations SEPARATOR "\n"»
				«op.getContent(name)»
			«ENDFOR»
			
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
		'''
	}

	def private getContent(Operation op, String moduleName) {
		paramsHelper.reset
		'''
			router.«op.method»('«op.path.expressPathString»', (req, res) => {
				new «moduleName»Handler(req.app.locals.db).«op.methodName»(«op.argList.join(", ")»)
				.then((response) => handle(res, response))
				.catch((error) => res.status(error.code).json(error));
			});
		'''
	}

	def private getArgList(Operation op) {
		op.allParameters.map[
			switch it {
				Parameter: it.expressExpr
				RequestBody: "req.body"				
			}
		]
	}

	override getRelativeFile() {
		return '''controllers/«name».js'''
	}
}
