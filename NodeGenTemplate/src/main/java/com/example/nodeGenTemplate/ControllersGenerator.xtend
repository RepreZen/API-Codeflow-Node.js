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
	extension ModuleNameHelper = new ModuleNameHelper

	override generate(OpenApiDocument model) throws GenerationException {
		for (entry: model.asKaizenOpenApi3.operationsByTag.entrySet) {
			new ControllersFile(context, entry.key.moduleName, entry.value).generate			
		}
	}
}

class ControllersFile extends GeneratedFile {
	extension ModelHelper = new ModelHelper
	extension MethodNameHelper = new MethodNameHelper
	extension ParamsHelper = new ParamsHelper
	
	val List<Operation> operations
	val String name

	new(IGenTemplateContext context, String name, List<Operation> operations) {
		super(context, true)
		this.name = name
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
				if (!res.headersSent) {
					res.status(response === undefined ? 201 : 200);
					return response === undefined ? res.end() : res.json(response);
				}
			}
			
			module.exports = router;
		'''
	}

	def private getContent(Operation op, String moduleName) {
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
