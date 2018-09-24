package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi3.OpenApi3DynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.OpenApi3
import com.reprezen.kaizen.oasparser.model3.Operation
import java.util.HashSet
import java.util.List

class HandlersGenerator extends OpenApi3DynamicGenerator {
	extension ModelHelper = new ModelHelper
	extension ModuleNameHelper = new ModuleNameHelper

	var OpenApi3 model
	val generatedOps = new HashSet<Operation>()

	override generate(OpenApi3 model) throws GenerationException {
		this.model = model;
		for (tag : model.allTags) {
			generate(tag, model)
		}
		generate(null, model)
	}

	def private generate(String tag, OpenApi3 model) {
		val allOps = model.paths.values.map[path|path.operations.values].flatten.toList
		// filter for matching tag if provided tag is not null
		val tagOps = allOps.filter[tag === null || it.tags.contains(tag)].toList
		// skip already-generated operations
		val ops = tagOps.filter[!generatedOps.contains(it)]
		if (!ops.empty) {
			new HandlersFile(context, tag.moduleName, ops.toList).generate()
			generatedOps.addAll(ops)
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
		'''
	}

	def private getContent(Operation op) {
		'''
			«op.methodName»(«op.parameterNameList») {
				// sample code
				try {
					«FOR param : op.parameterNameList»
						«param» = validate_«param»(«param»)
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
