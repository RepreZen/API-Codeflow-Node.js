package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi.OpenApiDocument
import com.modelsolv.reprezen.generators.api.template.AbstractDynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.Operation
import java.util.List

class HandlersGenerator extends AbstractDynamicGenerator<OpenApiDocument> {
	extension ModelHelper = new ModelHelper
	extension ModuleNameHelper = new ModuleNameHelper

	override generate(OpenApiDocument model) throws GenerationException {
		for (entry : model.asKaizenOpenApi3.operationsByTag.entrySet) {
			new HandlersFile(context, entry.key.moduleName, entry.value).generate
		}
	}
}

class HandlersFile extends GeneratedFile {
	extension MethodNameHelper = new MethodNameHelper
	extension ParamsHelper = new ParamsHelper

	val List<Operation> operations
	val String name

	new(IGenTemplateContext context, String name, List<Operation> operations) {
		super(context, false)
		this.name = name
		this.operations = operations
	}

	override getContent() {
		'''
			// jshint esversion:6, latedef:nofunc
			"use strict";
					
			class «name»Handler {
				constructor(db) {
					this.db = db;
				}
				
				«FOR op : operations SEPARATOR "\n"»
					«op.getContent»
				«ENDFOR»
			}				
			
			«FOR paramName : operations.map[it.parameterNameList].flatten.toSet SEPARATOR "\n"»
				«paramName.getValidatorSample»
			«ENDFOR»
			
			module.exports = «name»Handler;
		'''
	}

	def private getContent(Operation op) {
		'''
			«op.methodName»(«op.parameterNameList.join(", ")») {
				// sample code
				try {
					«FOR param : op.parameterNameList»
						«param» = validate_«param»(«param»);
					«ENDFOR»
				} catch(error) {
					return Promise.reject(error);
				}
				let result = null; // compute desired result
				return Promise.resolve(result);
			}
		'''
	}

	def private getValidatorSample(String name) {
		'''
			function validate_«name»(«name») {
				// check and/or alter parameter value as needed.
				// return value to be used in handler, or throw
				// an exception of the form {code, message} if
				// validation fails
				return «name»;
			}
		'''
	}

	override getRelativeFile() {
		return '''handlers/«name».js'''
	}

}
