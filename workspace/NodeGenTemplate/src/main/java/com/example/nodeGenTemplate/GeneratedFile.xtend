package com.example.nodeGenTemplate

import com.modelsolv.reprezen.generators.api.template.IGenTemplateContext
import java.io.File
import java.io.FileWriter

abstract class GeneratedFile {
	
	val protected IGenTemplateContext context
	val boolean overwrite
	
	new(IGenTemplateContext context) {
		this(context, true)
	}
	
	new(IGenTemplateContext context, boolean overwrite) {
		this.context = context;
		this.overwrite = overwrite;
	}
	
	
	def generate() {
		val outFile = new File(context.outputDirectory, relativeFile)
		if (overwrite || !outFile.exists) {
			outFile.parentFile.mkdirs
			var FileWriter writer = null
			try {
				writer = new FileWriter(outFile)
				writer.write(content)
			} finally {
				writer?.close
			}
		}
	}
	
	def String getContent()
	
	def String getRelativeFile()
}