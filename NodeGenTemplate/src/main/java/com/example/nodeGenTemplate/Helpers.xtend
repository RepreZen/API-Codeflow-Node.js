package com.example.nodeGenTemplate

import com.reprezen.jsonoverlay.Overlay
import com.reprezen.kaizen.oasparser.model3.OpenApi3
import com.reprezen.kaizen.oasparser.model3.Operation
import com.reprezen.kaizen.oasparser.model3.Parameter
import com.reprezen.kaizen.oasparser.model3.Path
import com.reprezen.kaizen.oasparser.model3.RequestBody
import com.reprezen.kaizen.oasparser.ovl3.PathImpl
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.IdentityHashMap
import java.util.List
import java.util.regex.Pattern

class ModelHelper {

	def getAllTags(OpenApi3 model) {
		val result = new ArrayList<String>
		// model level tags come first, followed by any other tags 
		// appearing in operations
		result.addAll(model.tags.map[it.name])
		result.addAll(model.allOperations.map[it.tags].flatten)
		result.toSet
	}

	def getOperationsByTag(OpenApi3 model) {
		val used = new HashSet<Operation>
		val result = new HashMap<String, List<Operation>>()
		for (tag : model.allTags) {
			val tagOps = model.allOperations.filter[it.tags.contains(tag)].filter[!used.contains(it)]
			if (!tagOps.empty) {
				result.put(tag, tagOps.toList)
				used.addAll(tagOps)
			}
		}
		val noTagOps = model.allOperations.filter[!used.contains(it)]
		if (!noTagOps.empty) {
			result.put(null, noTagOps.toList)
		}
		result
	}

	def getAllOperations(OpenApi3 model) {
		model.paths.values.map[it.operations.values].flatten.toSet
	}

	def String getMethod(Operation op) {
		Overlay.of(op).pathInParent
	}

	def Path getPath(Operation op) {
		Overlay.of(op).parentPropertiesOverlay as Path
	}

	def getPathString(Path path) {
		Overlay.of(path as PathImpl).pathInParent
	}

	def getName(Path path) {
		val pathString = path.pathString
		val parts = pathString.split("/").filter[!it.empty]
		val end = (0 ..< parts.length).map [
			if(parts.get(it).startsWith("{")) it
		].filter[it !== null].head ?: parts.length
		parts.toList.subList(0, end).join("_")
	}

	val static private paramPattern = Pattern::compile("\\{([a-zA-Z0-9_]+)\\}")

	def expressPathString(Path path) {
		paramPattern.matcher(path.pathString).replaceAll(":$1")
	}
}

abstract class NameHelper<T> {
	val protected usedNames = new HashSet<String>
	val protected nameMap = new IdentityHashMap<T, String>

	def protected getName(T value) {
		if (!nameMap.containsKey(value)) {
			nameMap.put(value, value.preferredName.process)
		}
		nameMap.get(value)
	}

	def protected abstract String getPreferredName(T value)

	def protected String process(String name) {
		return name.normalize.disambiguate
	}

	def normalize(String name) {
		val norm = name.replaceAll("[^a-zA-Z0-9_]", "_")
		if (Character::isDigit(Character::valueOf(norm.charAt(0)))) {
			"_" + norm
		} else {
			norm
		}
	}

	def String disambiguate(String name) {
		var result = name
		var suffix = 1
		while (usedNames.contains(result)) {
			result = '''«name»_«suffix++»'''
		}
		usedNames.add(result)
		result
	}
	
	def reset() {
		usedNames.clear
		nameMap.clear
	}
}

class ModuleNameHelper extends NameHelper<String> {
	extension ModelHelper = new ModelHelper

	def getModuleName(String tagName) {
		getName(tagName)
	}

	def getAllModuleNames(OpenApi3 model) {
		model.allTags.map[it.moduleName]
	}

	override protected getPreferredName(String tagName) {
		tagName.toFirstUpper ?: "Untagged"
	}
}

class MethodNameHelper extends NameHelper<Operation> {

	extension ModelHelper = new ModelHelper

	def getMethodName(Operation op) {
		return getName(op)
	}

	override protected getPreferredName(Operation op) {
		op.operationId ?: '''«op.path.name»_«op.method»'''
	}
}

class ParamNameHelper extends NameHelper<Parameter> {

	new() {
		usedNames.add("body") // reserve this for a request body
	}

	override protected getPreferredName(Parameter param) {
		return param.name
	}

	def getVarName(Parameter param) {
		getName(param)
	}

}

class ParamsHelper {
	extension ParamNameHelper paramNameHelper = new ParamNameHelper
	extension ModelHelper = new ModelHelper

	def getParamName(Parameter param) {
		return getName(param)
	}

	def getAllParameters(Operation op) {
		val List<Object> params = new ArrayList<Object>(op.parameters)
		for (param : op.path.parameters) {
			if (!params.map[it as Parameter].exists[it.name == param.name && it.in == param.in]) {
				params.add(param)
			}
		}
		if (Overlay.of(op.requestBody).isPresent) {
			params.add(op.requestBody)
		}
		return params
	}

	def getParameterNameList(Operation op) {
		op.allParameters.map [
			switch it {
				Parameter: it.paramName
				RequestBody: "body"
			}
		]
	}

	def getExpressExpr(Parameter param) {
		val varName = param.varName
		switch param.in {
			case "path": '''req.params.«varName»'''
			case "query": '''req.query.«varName»'''
			case "header": '''req.header("«varName»")'''
			case "cookie": '''req.cookies.«varName»'''
		}
	}
	
	def reset() {
		paramNameHelper.reset
	}
}
