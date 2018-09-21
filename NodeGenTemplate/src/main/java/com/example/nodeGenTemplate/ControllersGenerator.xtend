package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi3.OpenApi3DynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import com.reprezen.kaizen.oasparser.model3.OpenApi3
import com.reprezen.kaizen.oasparser.model3.Operation
import com.reprezen.kaizen.oasparser.model3.Tag
import java.util.HashSet
import java.util.List

class ControllersGenerator extends OpenApi3DynamicGenerator {
	var OpenApi3 model
	val generatedOps = new HashSet<Operation>()

	override generate(OpenApi3 model) throws GenerationException {
		this.model = model;
		for (tag : model.tags) {
			tag.generate(model)
		}
		(null as Tag).generate(model)
	}

	def private generate(Tag tag, OpenApi3 model) {
		val allOps = model.paths.values.map[path|path.operations.values].flatten.toList
		// filter for matching tag if provided tag is not null
		val tagOps = allOps.filter[tag === null || it.tags.contains(tag.name)].toList
		// skip already-generated operations
		val ops = tagOps.filter[!generatedOps.contains(it)]
		new ControllersFile(context, tag, ops.toList).generate()
		generatedOps.addAll(ops)
	}
}

class ControllersFile extends GeneratedFile {
	extension Helper helper = new Helper

	val List<Operation> operations
	val Tag tag

	new(IGenTemplateContext context, Tag tag, List<Operation> operations) {
		super(context, true)
		this.tag = tag
		this.operations = operations
	}

	override getContent() {
		operations.map[it.content].join
	}

	def private getContent(Operation op) {
		val name = op.getMethodName(tag)
		'''
			// «name»
		'''
	}

	override getRelativeFile() {
		return '''controllers/«tag?.name?.normalize ?: "Untagged"».js'''
	}

}
