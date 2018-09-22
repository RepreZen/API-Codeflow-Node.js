package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi3.OpenApi3DynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.OpenApi3
import com.reprezen.kaizen.oasparser.model3.Operation
import java.util.HashSet
import java.util.List

class ControllersGenerator extends OpenApi3DynamicGenerator {
	extension Helper helper = new Helper
	var OpenApi3 model
	val generatedOps = new HashSet<Operation>()

	override generate(OpenApi3 model) throws GenerationException {
		this.model = model;
		for (tag : model.allTags) {
			tag.generate(model)
		}
		(null as String).generate(model)
	}

	def private generate(String tag, OpenApi3 model) {
		val allOps = model.paths.values.map[path|path.operations.values].flatten.toList
		// filter for matching tag if provided tag is not null
		val tagOps = allOps.filter[tag === null || it.tags.contains(tag)].toList
		// skip already-generated operations
		val ops = tagOps.filter[!generatedOps.contains(it)]
		if (!ops.empty) {
			val name = tag?.normalize ?: "Untagged"
			new ControllersFile(context, name, ops.toList).generate()
			generatedOps.addAll(ops)
		}
	}
}

class ControllersFile extends GeneratedFile {
	extension Helper helper = new Helper

	val List<Operation> operations
	val String name

	new(IGenTemplateContext context, String name, List<Operation> operations) {
		super(context, true)
		this.name = name
		this.operations = operations
	}

	override getContent() {
		'''
			// jshint esversion: 6
			
			const router = require('express').Router();
			const «name»Handler» = require('../handlers/«name»');
			
			«FOR op : operations SEPARATOR "\n"»
				«op.getContent(name)»
			«ENDFOR»
			
			module.exports = router;
		'''
	}

	def private getContent(Operation op, String moduleName) {
		'''
			router.«op.method»('«op.path.expressPathString»', (req, res) => {
				new «moduleName»Handler(req.app.locals.db).«op.methodName»(«op.argList»)
				.then((response) => res.status(200).json(response))
				.catch((error) => res.status(error.code).send(error.message));
			});
		'''
	}
	
	def private getArgList(Operation op) {
		// TODO implement this
		""
	} 

	override getRelativeFile() {
		return '''controllers/«name».js'''
	}

}
