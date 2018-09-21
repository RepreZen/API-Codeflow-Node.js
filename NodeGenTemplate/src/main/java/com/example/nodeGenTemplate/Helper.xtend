package com.example.nodeGenTemplate

import com.reprezen.jsonoverlay.Overlay
import com.reprezen.kaizen.oasparser.model3.Operation
import com.reprezen.kaizen.oasparser.model3.Tag
import com.reprezen.kaizen.oasparser.ovl3.PathImpl
import java.nio.file.Path
import java.util.Collection
import java.util.IdentityHashMap

class Helper {
	val opMethodNames = new IdentityHashMap<Operation, String>

	def getMethodName(Operation op, Tag tag) {
		if (!opMethodNames.containsKey(op)) {
			val name = op.operationId ?: {
				if (tag != null) '''«tag.name»_«op.method»'''
			} ?: {
				'''«op.path.name»_«op.method»'''
			}.normalize.disambiguate(opMethodNames.values)
			opMethodNames.put(op, name)
		}
		opMethodNames.get(op)
	}

	def String getMethod(Operation op) {
	}

	def String normalize(String name) {
		val norm = name.replaceAll("^[a-zA-Z0-9_]", "_")
		if (Character::isDigit(Character::valueOf(norm.charAt(0)))) {
			"_" + norm
		} else {
			norm
		}
	}

	def Path getPath(Operation op) {
		Overlay.of(op).parent as Path 
	}

	def getName(Path path) {
		val pathString = Overlay.of(path as PathImpl).pathInParent
		val parts = pathString.split("/").filter[!it.empty]
		val end = (0 ..< parts.length).map [
			if(parts.get(it).startsWith("{")) it
		].filter[it !== null].head ?: parts.length
		parts.toList.subList(0, end).join("_")
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
