# API CodeFlow Node.js

This project serves as a demo for an [API CodeFlow](http://rzen.io/APICodeFlow) approach to API
service implementation. This entails the following three steps,
repeated as the API evolves:

1. **Design** your API in [OpenApi](https://github.com/OAI/OpenAPI-Specification).
2. **Generate** stub code in Node.js (JavaScript).
3. **Implement** your business logic.

This demo will create a working API to manage a database of live pets for a pet store. (No animals have been harmed or killed in the creation of
this demo.)

## Custom Code Generation

A custom code generator was built especially for this demo, to show how you can tailor code generation to meet your specific needs. This code
generator is not complete and lacks a number of useful features, but it does include all of the following:

* Automatic generation of _controllers_ and _handlers_ for all operations defined by the API. The controllers are fixed code that are not
  intended for user editing and will be overwritten during regeneration. They serve as bridges between the service framework and the
  handlers. Handlers are where business logic belongs. Handlers are never overwritten by the generator.

* Controllers and handlers are organized by tags to simplify code management.

* Automatic integration of Swagger-UI, with options to reroute Try-It-Out requests to your running service, overriding server definitions in the
  model.

* A very simple built-in database to with basic CRUD capabilities.

* ...

## Working Through the Demo

### Overview

The demo proceeds in five phases (plus some initial set-up). ~~There are branches defined for each phase, which you can use to quickly bring your
workspace up to that point of the demo, rather than manually working through each step.~~ _Note: the canned branches currently do not work properly becaues of maven `pom.xml` files in the example model project created in phase 2. These files include absolute paths that depend on the location of the working tree of this demo repository, and of course this will differ for anyone attempting to follow the demo. Fixing this will require changes to RepreZen API Studio, so until these changes are made, we will use ~~strike-through~~ formatting to deprecate use of these canned branches. Fortunately, nearly all the demo steps are easy to perform manually, and where they are not, the instructions will indicate how to make selective use of the canned branches to complete the demo._

The phases are:

0. Setup - install and launch RepreZen API Studio, and install Nodeclipse from the Eclipse Marketplace, so you'll be able to work with Node.js
   code.

1. Obtain the custom generator from the demo repository and activate it in your workspace.

2. **Design** - Create one of the standard OpenAPI v3 example models available in RepreZen API Studio.

3. **Generate** - Prepare a Node.js project for the service implementation, and use the code generator to populate it.

4. **Implement** - Write your business logic into the generated stubs.

5. Iterate (**Design** => **Generate** => **Implement**) in order to add a new method to the API

So let's dig in

### Phase 0 - Setup

If you don't already have RepreZen API Studio installed, you'll want to visit https://www.reprezen.com and sign up for a free trial.

Once you're up and running, you should install **Nodeclipse** from _Eclipse Marketplace_, which you can find on the Help menu. Follow the
instructions, and after a restart you'll have added robust support for Node.js projects to the product.

**N.B.** There is an unimportant conflict involving a particular feature required by Nodeclipse and already present (in a different version) in
API Studio. During installation you'll be informed of this asd presented with a recommendation as to how to proceed. You should accept the
recommendation.

Your final setup step, if you haven't done it already, is to clone this project to a local working directory on your machine.

### Phase 1 - GenTemplate

In this step you will change your workspace to one provided in the demo project, having checked out a branch that includes the generator as a
workspace project (in contrast to the numerous pre-packaged geneartors that are available out of the box in API Studio).

Follow these steps:

1. In your demo project working directory, checkout the `01.gentemplate` branch.

2. In API Studio, use _File -> Switch workspace -> Other..._ and navigate to your working directory and then into the `workspace` folder
   therein.

3. API Studio will restart.

4. Use _File -> Import..._, and in the resulting dialog select the _Maven / Existing Maven Projects_ option and click _Next_. In the next panel,
   use the _Browse_ button to locate your working directory and click _Next_. You should check tne _NodeGenTemplate_ project, and click _Finish_.

5. There will be small delay while this project builds for the first time on your machine.

In some cases, the initial build will not work correctly, due to a bug that we hope to remedy shortly. You will know this from red error markers
on some of the folders inside the the main _NodeGenTemplate_ project folder. If you see them, right-cliick on that project folder, select _Run As
-> Maven build..._, and then type `compile` into the _Goal_ field before pressing _Run_.

### Phase 2 - Design

_~~The end state of this phase is captured in branch `02.petstore`.~~_

We won't actually design a model here. Instead, we'll just use one of the OpenApi3 models available from the API Studio Examples Wizard.

Follow these steps:

1. Click on the drop-down arrow of the _New_ tool in the toolbar, just under the _File_ menu.

2. Select _RepreZen Examples_ to open the Examples Wizard.

3. Click on the _OpenAPI v3_ tab.

4. Select the _Expanded Pet Store (v3)_ example, and press _Finish_.

5. You should see a new project in your workspace, and the example model file itself will automatically open in an editor.

6. Browse through the model briefly to familiarize yourself with its operations and other components.

### Phase 3 - THe Pet Store Service

_~~The end state of this phase is captured in branch `03.service`.~~_

This is where we'll generate code for the model we created, in phase 2. We'll arrange for the generated files to land directly in a
Node.js project that we set up for that purpose. Regeneration cycles will all continue to feed into that project.

Follow these steps:

1. Right-click in the _Project Explorer_ pane and use _New -> Node.js Project_ to bring up a wizard.

2. Type `PetStoreService` for the _Project name_.

3. Select the _none/empty_ template, then press _Finish. A new project appears in your workspace.

4. In your model project, locate the `petstore-expanded.yaml` file in the `models` folder, and click on it.

5. Click on the _Create a New GenTarget_ button in the toolbar, just to the left of the _Generate_ button/menu. (Note: If you do not see this in the toolbar, be sure that you are in the **RepreZen** perspective, by clicking on the appropriate button on the far right of the toolbar.)

6. Type "node" in the resulting dialog's search box, and you should see our **NodeGenTempalte** generator. Select it and press _Finish_. A new
GenTarget is created in your project, and the `.gen` file that describes it opens in an editor.

7. Make and save the following changes in this file:

   a. Near the top, change the value for `relativeOutputDir` to
`../../../../PetStoreService`. This is what will cause generated files to flow directly into the project we jsut created.

   b. Set `pathPrefix` to `/api`, to align with the path prefix listed in the first _server_ defined in our model. This will cause the running
service to properly recognize and route requests sent from Swagger-UI.

   c. Set `swaggerUIPath` to `api-ui`. The default, `/api`, clashes with the `pathPrefix` that is dictated by the server definition in our
   model. (Of course, we could also just change that server definition to use a different path prefix, or just remove it altogether.)

8. Run the generator, by clicking on the big `Generate` button in the toolbar. (Since we've been actively editing the `.gen` file for the
_NodeGenTemplate_ generator, the menu should show that as the generator to run. If not, click instead on the small arrow to the right, and select
_NodeGenTemplate_ from the list of targets.)

9. Even though the service project files are now present, they will not appear in Project Explorer until you cause a refresh of the project files. Right-click on `PetStoreProject` in _Project Explorer_ and then select _Refresh_ to do this.

### Phase 4 - Implementing Business Logic

_~~The end state of this phase is captured in branch `04.implement`.~~_

Now it's time to write the code that will implement the business logic of our API service.

You should only need to touch files in the `handlers` folder of the `PetStoreService` project. In this case there's only one file -
`Untagged.js`. Normally, there could be several files here, named after the tags defined in the model. When operations are grouped using tags,
this allows the overall implementation code base to be split into more manageable pieces. In our example model, tags are not used, so all the
handlers ended up in a single `Untagged` source file.

If you're reasonably proficient with Javascript, Node.js and Express.js, you may want to take a crack at this yourself. But you can also skip
forward by chekcing out the necessary files from branch `04.implement` of the demo repo. In that case you may want to take a look at the before and after images of
`handlers/Untagged.js`, just to get a sense of what's going on.

To check out final the implementation from the repo, use this command, from the root of your working tree:

```
git checkout origin/04.implement -- workspace/PetStoreService
```

You'll need to refresh the `PetStoreService` again to see the changes in API Studio.

The basic design of the handlers goes like this:

* Each controller method implements the logic for a single operation defined in the model.
* The methods are named after operation ids if they exist. Otherwise they're a combination of the operation's path string (up to but not
  including the first path parameter) and the operation's HTTP method. Name collisions are disambiguated with trailing integers.
* Each method is declared with a parameter list that corresponds to the operation's declared parameters in the model. If any path-level
  parameters are inhereted by this operation, they follow the operation's own parameters. If the operation defines a `RequestBody` there will be
  a final `body` parameter.
* The handler is expected return a new `Promise` that has either been `resolve`d to a value for the response payload, or `reject`ed with an error
   object that should have `code` and `message` properties.
* The non-error response can also be an object with `code` and `value` properties, in which case the `code` value will be used for the HTTP
  status code, and the `value` property will be used for the payload.
* If the response payload is `undefined`, no response will be provided, and the default status code will be 204. Otherwise the default status
  code will be 200.
* All payloads - including the error objects - are sent as JSON values.
* Each handler makes calls to validators, one for each parameter. Stubs for the validators are also provided, after all the handlers.
* Validators should throw an error object if validation fails.
* Each validator that does not throw must return a final value for the parameter it checked. This is where, e.g. a string value from a query
  parameter is converted into an integer after testing that it's syntactically valid.

If you want to run your implementation, you can follow these steps:

1. Right-click on the `package.json` file in the service project, and select _Run As -> npm install_. You'll only need to do this again if you
change the file or remove the `node_modules` directory.
2. Right click on the `PetStoreService` project name in _Project Explorer_, and select _Refresh_. This is needed in order for the results of the
build to become available in the project, since the build itself is carried out in a separate process.
3. Right click on `app.js` in the service project, and select _Run As -> Node Application_. You should see a start-up message in a console pane
that makes itself visible.
4. Visit `http://localhost:3000/api-ui` in a web browser. You should see Swagger-UI displaying your model. The "Try It Out" buttons will work,
and requests will be directed to your running instance, regardless of the server definitions in the model itself.

### Phase 5 - Iterate

_~~The end state of this phase is captured in branch `05.patch`.~~_

Missing from the API model is an operation that allows modification of selected properties of a pet. In phase 5 we add a `patch` operation  to the
`/pets/{petId}` path to supply this capability. The steps are:

1. Add the operation to the model file, `petstore-expanded.yaml` in the model project.
2. Rerun the generator. Everything but the handler files will be refreshed and will reflect the additional operation.
3. Add a handler for the new patch method to the handler file (the corresponding controller will already be updated).

To check out a working implementation from the demo repository, use the following command (then refresh `PetStoreService` project):

```
git checkout origin/05.patch -- workspace/PetStoreService 'workspace/Expanded Pet Store (v3)/models'
```

And that's it. At that point you should be able to re-launch the application and make use of the nifty new patch method.

_Note_: If you attempt to re-launch the app and see an error message indicating that the port is already in use, it's because your prior launch is still running and still listening on port 3000. To terminate that launch, open the _Console_ view (use _Window -> Show view -> Other..._ and then select the _General/Console_ view and click _Open_.) Near the right end of that view's toolbar, open the _Display Selected Console_ menu, and select a console labled _PetStoreService..._ that is not marked as _terminated_. You'll then see a square red toolbar button that you can use to terminate the launch. At that point you should be able to successfully re-launch the service app.


### More

THe next thing that we intend to add to this demo is provisioning preloaded data in the internal database. You may have noticed the `preloadDataFile`
parameter in the `.gen` file defining the GenTarget. It's `null` by default, but it can be changed to the path of a file relative to project's
root directory (where `app.js` lives).

The file itself should be a `.js` file (it's loaded using `require`) that exports a single object value. Property names in that object are record
types (we only use `Pet` in this demo), and property values are arrays containing records of that type.

An example of what this file might look like for the PetStoreService is:

```Javascript
{
  Pet: [
    {name: "Snoopy", tag: "dog"},
    {name: "Rango", tag: "lizard"},
    ...
  ]
}
```
