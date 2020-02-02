//gathers information from the relations between classes and other classes and interfaces and visualizes this in an edge

module ClassEdges

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import util::Math;

import ClassNodes;

alias Relation = tuple[loc child,loc parent];

/* Returns the extends property of the M3 model in a child - parent tuple, containing the class definitions of the uses relation */
public set[Relation] getExtends(M3 model) {
	return { e | e <- model.extends};
}

/* Returns the implements property of the M3 model in a child - parent tuple, containing the class definitions of the uses relation */
public set[Relation] getImplements(M3 model) {
	return { e | e <- model.implements};
}

//search for attributes
/* Returns the dependency property of the M3 model in a child - parent tuple, containing the class definitions of the uses relation for classes and interfaces */
public set[Relation] getDependency(M3 model) {
	return { <x,y> | <x,y> <- model.typeDependency, (x.scheme=="java+class" || x.scheme=="java+interface") && (y.scheme=="java+class" || y.scheme=="java+interface")};
}

/* Returns the uses proeprty of the M3 model in a child - parent tuple, containing the class definitions of the uses relation for classes and interfaces */
public set[Relation] getUses(M3 model) {
	return { <x,y> | <x,y> <- model.uses, y.scheme=="java+class" || y.scheme=="java+interface"};
/*	rel[loc location, loc definition] uses = { <x,y> | <x,y> <- model.uses, y.scheme=="java+class" || y.scheme=="java+interface"};
	//keep only uses of defined classes
	set[loc] classDefinitions =  { d | <d,_> <- getDeclarations()};
	set[str] classLocationUris =  { l.uri | <_,l> <- getDeclarations()};
//	println(classDefinitions);
//	println(uses);
	rel[loc child, loc parent] edges = {};
	for (u <- uses) {
		tuple[loc child,loc parent] newEdge;
		if (u.location.uri in classLocationUris && u.definition in classDefinitions) {
		println("<u.location.uri> and <u.definition>");
			set[loc] defs = { d | <d,l> <- getDeclarations(), l.uri == u.location.uri};
			newEdge = <getOneFrom(defs),u.definition>;
			println(newEdge);
			edges += newEdge;
		}
	}
	return edges;
*/
}


public list[Edge] makeClassEdges(set[Relation] relations) {
	return [makeEdge(n) | n <- relations];
/*
//	rel[loc child,loc parent] relations = getUses() + getClassExtends() + getImplementations() + getDependency();
	set[loc] classDefinitions =  { l | <l,_> <- getDeclarations()};

	Figures nodes = makeClassNodes();
	list[str] values= [n.child.file | n <- relations];
	
//	println("classdefinitions;\n<classDefinitions>");
//	println("relations:\n<values>");
	list[Edge] edges = [makeEdge(n) | n <- relations, n.child in classDefinitions && n.parent in classDefinitions];
	println(size(edges));
	showGraph(nodes, edges);
*/
}

public Edge makeEdge(Relation n) {
	return edge(n.parent.uri, n.child.uri, fromArrow(ellipse(size(8), fillColor("black"))), lineStyle(getLineStyle(n.parent)));
}

public str getLineStyle(loc definition) {
	switch(definition.scheme) {
		case "java+interface": return "dash";
	}
	return "solid";
}