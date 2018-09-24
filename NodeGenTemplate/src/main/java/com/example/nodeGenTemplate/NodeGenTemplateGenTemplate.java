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
