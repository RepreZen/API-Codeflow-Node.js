package com.example.nodeGenTemplate;

import com.modelsolv.reprezen.generators.api.GenerationException;
import com.modelsolv.reprezen.generators.api.openapi.OpenApiGenTemplate;

public class NodeGenTemplateGenTemplate extends OpenApiGenTemplate {

	@Override
	public String getName() {
		return "NodeGenTemplate";
	}

	@Override
	public String getId() {
		return "com.example.nodeGenTemplate.NodeGenTemplateGenTemplate";
	}

	@Override
    public void configure() throws GenerationException {
        defineOpenApiSource();
        define(parameter().named("port") //
        		.withDescription("Port to listen on for HTTP requests.") //
        		.withDefault(3000));
        define(parameter().named("host") //
        		.withDescription("Server host name.", //
        				"This is used when overriding host+port in Swagger-UI testing.")//
        		.withDefault("localhost"));
        define(parameter().named("overrideOrigin") //
        		.withDescription("Whether to override host+port in Swagger-UI testing.") //
        		.withDefault(true));
        define(parameter().named("pathPrefix") //
        		.withDescription("Path prefix added to each path for routing.",
        				"This can be used to match the server defined in the model for Swagger-UI testing.") //
        		.withDefault(null));
        define(parameter().named("swaggerUIPath") //
        		.withDescription("GET request path to deliver Swagger-UI.")
        		.withDefault("/api"));
        define(parameter().named("modelPath") //
        		.withDescription("URL path for delivering model file", //
        				"The file is saved and served out of the public folder") // 
        		.withDefault("swagger.yaml"));
        define(parameter().named("publicFolder") //
        		.withDescription("Folder from which to serve static public content.")
        		.withDefault("public"));
        define(parameter().named("useFakeDB") //
        		.withDescription("Whether to make use of provided FakeDB module instead of a real database.")
        		.withDefault(true));
        define(parameter().named("preloadDataFile") //
        		.withDescription("Path to look for a .js file that defines data to",
        				"be preloaded into the FakeDB database") //
        		.withDefault(null));
        define(dynamicGenerator().named("app") //
        		.using(AppGenerator.class));
        define(dynamicGenerator().named("controllers") //
                .using(ControllersGenerator.class));
        define(dynamicGenerator().named("handlers") //
                .using(HandlersGenerator.class));
        define(dynamicGenerator().named("model") //
        		.using(ModelGenerator.class));
        define(staticResource().copying("code").to("."));
    }
}
