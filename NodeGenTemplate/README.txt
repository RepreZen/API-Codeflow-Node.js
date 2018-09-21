==================================================
GenTemplate: NodeGenTemplate
==================================================

This project contains an example of a GenTemplate to process OpenApi3
models. A GenTemplate is a Java class that transforms an input API model 
into API documentation, software implementations of API server or client
libraries, conversions to other model formalisms, or anything else you
might need from your model.

The files in this project are sprinkled with comments that should help
you understand how to transform this project into a GenTemplate that does
what you need, using a monkey-see monkey-do approach.

Full documentation at http://docs.reprezen.com/codegen_custom_gentemplate
explains the features you'll find in this project, as well as additional
features not used here.

The code here is actually a mixture of Java and Xtend. Xtend is a
programming language that extends Java in a number of very interesting
ways. Of particular interest for GenTemplate creation is Xtend's
built-in template capability. Look in this project's src/main/java folder,
in files with the ".xtend" extension, for blocks of HTML surrounded by 
triple-apostrophes ('''). Within each template, you will see Xtend
expressions surrounded by guillemet characters (« and ») that are evaluated
and interpolated into the template at execution time.

For full details on Xtend, see https://www.eclipse.org/xtend.

For convenience while working on your GenTemplate you should probably
switch to the Java Perspective, rather than the default RepreZen perspective.
The first time you use a perspective, you can activate it from the toolbar
menu via "Window > Perspective > Open perspective > Other..." After that 
you'll see it listed, with other perspectives you've used, at the right
end of the toolbar. Remember to switch back to RepreZen perspective when
you again want to work with RepreZen features, as they will not be
available from other perspectives.