package com.example.nodeGenTemplate

import com.reprezen.jsonoverlay.Overlay
import com.reprezen.kaizen.oasparser.model3.OpenApi3
import com.reprezen.kaizen.oasparser.model3.Operation
import com.reprezen.kaizen.oasparser.model3.Path
import com.reprezen.kaizen.oasparser.ovl3.PathImpl
import java.util.ArrayList
import java.util.Collection
import java.util.IdentityHashMap
import java.util.regex.Pattern

class Helper {
	val opMethodNames = new IdentityHashMap<Operation, String>

	def getAllTags(OpenApi3 model) {
		val result = new ArrayList<String>
		// model level tags come first, followed by any other tags 
		// appearing in operations
		result.addAll(model.tags.map[it.name])
		result.addAll(model.allOperations.map[it.tags].flatten)
		result.toSet
	}

	def getAllOperations(OpenApi3 model) {
		model.paths.values.map[it.operations.values].flatten.toSet
	}
	
	def getMethodName(Operation op) {
		op.getMethodName(null)
	}

	def getMethodName(Operation op, String tag) {
		if (!opMethodNames.containsKey(op)) {
			val name = op.operationId ?: {
				if (tag != null) '''«tag»_«op.method»'''
			} ?: {
				'''«op.path.name»_«op.method»'''
			}.normalize.disambiguate(opMethodNames.values)
			opMethodNames.put(op, name)
		}
		opMethodNames.get(op)
	}

	def String getMethod(Operation op) {
		Overlay.of(op).pathInParent
	}

	def String normalize(String name) {
		val norm = name.replaceAll("[^a-zA-Z0-9_]", "_")
		if (Character::isDigit(Character::valueOf(norm.charAt(0)))) {
			"_" + norm
		} else {
			norm
		}
	}

	def Path getPath(Operation op) {
		Overlay.of(op).parentPropertiesOverlay as Path
	}

	def getName(Path path) {
		val pathString = path.pathString
		val parts = pathString.split("/").filter[!it.empty]
		val end = (0 ..< parts.length).map [
			if(parts.get(it).startsWith("{")) it
		].filter[it !== null].head ?: parts.length
		parts.toList.subList(0, end).join("_")
	}
	
	def getPathString(Path path) {
		Overlay.of(path as PathImpl).pathInParent		
	}
	
	val static private paramPattern = Pattern::compile("\\{([a-zA-Z0-9_]+)\\}")
	def expressPathString(Path path) {
		paramPattern.matcher(path.pathString).replaceAll(":$1")
	}

	def String disambiguate(String name, Collection<String> existing) {
		var result = name
		var suffix = 1
		while (existing.contains(result)) {
			result = '''«name»_«suffix++»'''
		}
		result
	}
}
