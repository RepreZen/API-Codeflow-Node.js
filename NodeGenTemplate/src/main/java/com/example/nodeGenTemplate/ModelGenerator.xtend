package com.example.nodeGenTemplate

import com.fasterxml.jackson.dataformat.yaml.YAMLMapper
import com.modelsolv.reprezen.generators.api.GenerationException
import com.modelsolv.reprezen.generators.api.openapi.OpenApiDocument
import com.modelsolv.reprezen.generators.api.template.AbstractDynamicGenerator
import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext

class ModelGenerator extends AbstractDynamicGenerator<OpenApiDocument> {

	override generate(OpenApiDocument model) throws GenerationException {
		new ModelFile(model, context).generate();
	}
}

class ModelFile extends GeneratedFile {

	val private OpenApiDocument model

	new(OpenApiDocument model, IGenTemplateContext context) {
		super(context)
		this.model = model
	}

	override getContent() {
		new YAMLMapper().writerWithDefaultPrettyPrinter.writeValueAsString(model.asJson)
	}

	override getRelativeFile() {
		val dir = context.genTargetParameters.get("publicFolder") ?: "public"
		val file = context.genTargetParameters.get("modelFile") ?: "swagger.yaml"
		'''«dir»/«file»'''
	}

}
