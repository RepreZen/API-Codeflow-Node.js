package com.example.nodeGenTemplate;
            
import com.modelsolv.reprezen.generators.api.GenerationException;
import com.modelsolv.reprezen.generators.api.openapi3.OpenApi3GenTemplate;
            

public class NodeGenTemplateGenTemplate extends OpenApi3GenTemplate {
          
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
        defineOpenApi3Source();
        define(dynamicGenerator().named("controllers") //
                .using(ControllersGenerator.class));
        
    }
}
