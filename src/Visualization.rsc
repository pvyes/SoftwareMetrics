module Visualization

import Prelude;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;

import ClassNodes;
import ClassEdges;
import ClassFields;

M3 model;
ClassNodes classNodes;

public void initializeVisualization(M3 m) {
	model = m;	
	classNodes = makeClassNodes(model);
}

/*Shows basic information of classes and interfaces in grid */
public void showClassesInGrid() {
	showInGrid([cn.classBox | cn <- classNodes]);
}

public void	showBasicClassGraph() {
	Figures classBoxes = [ cn.classBox | cn <- classNodes];
	set[Relation] relations = gatherClassRelations(model);
	list[Edge] classEdges = makeClassEdges(relations);	
	showGraph(classBoxes, classEdges);
}

/* Shows figures in a fixed grid on a 3 : 2 ratio*/
public void showInGrid(Figures nodes) {	
	//render in grid
	int columnsRatio = 3;
	int rowsRatio = 2;
	
	list[Figures] rows = [];
	int nrOfFigures = size(nodes);
	
	int nrOfColumns = ceil(sqrt(columnsRatio * nrOfFigures / rowsRatio));
//	int nrOfRows = ceil(nrOfColumns * rowsRatio / columnsRatio);
//	println("nrOfColumns = <nrOfColumns>"); 
//	println("nrOfRows = <nrOfRows>"); 
	
	int i = 0;
	Figures row = [];
	for (f <- nodes) {
		if (remainder(toRat(i, nrOfColumns)) == 0) {
			if (size(row) > 1) {
				rows += [row];
			}
			row = [];
		}
		row += f;
		i += 1;
		if (i >= size(nodes)) {
			rows += [row];
		}
	}
	render(grid(rows));
}

public void showClassDetails(loc definition) {
 	println("mouse clicked on <definition>");
 	set[Relation] relations = gatherClassRelations(model);
 	//filter relations
 	relations = {r | r <- relations, r.child == definition || r.parent == definition};	list[Edge] classEdges = makeClassEdges(relations);
 	// filter classnodes
 	Figures classBoxes = toList({cn.classBox | cn <- classNodes, r <- relations, cn.definition == r.child || cn.definition == r.parent});  
	showGraph(classBoxes, classEdges);
}

public void showGraph(nodes, edges) {
   render(graph(nodes, edges, hint("layered"), gap(50)));
}

public set[Relation] gatherClassRelations(model) {
	set[Relation] relations = {};
	relations += getExtends(model);
	relations += getImplements(model);
	relations +=  getDependency(model);	
//TODO	relations +=  getUses(model);	
	return filterRelations(model, relations);
}

public set[Relation] filterRelations(M3 model, set[Relation] relations) {
	set[loc] classDefinitions = {x | <x,y> <- model.declarations, x.scheme=="java+class" || x.scheme=="java+interface"};
	return filteredRelations = {n | n <- relations, n.child in classDefinitions && n.parent in classDefinitions};
}

public void showFieldNodes(/*model, classDefinition*/) {
	loc PROJECT = |project://Jabberpoint2|;
	M3 model = createM3FromEclipseProject(PROJECT); 
	Figures fieldboxes = [b | <l,b> <- makeFieldNodes(model/*, classDefinition*/)];
	render(makeFieldsBox(makeFieldNodes(model/*, classDefinition*/)));	
}
	

/* Keep only uses-relation of classes and interfaces which are defined in the class nodes 
public rel[loc child, loc parent] filter(rel[loc location, loc definition] uses) {
	rel[loc definition, loc location] declarations = {<x,y> | <x,y> <- model.declarations, x.scheme=="java+class" || x.scheme=="java+interface"};
	set[loc] classDefinitions =  { d | <d,_> <- declarations};
	set[str] classLocationUris =  { l.uri | <_,l> <- declarations};
	rel[loc child, loc parent] relations = {};
	for (u <- uses) {
		tuple[loc child,loc parent] newRelation;
		if (u.location.uri in classLocationUris && u.definition in classDefinitions) {
			set[loc] defs = { d | <d,l> <- getDeclarations(), l.uri == u.location.uri};
			newRelation = <getOneFrom(defs),u.definition>;
			relations += newRelation;
		}
	}
	return relations;
}

/*
 public void show() {

 	b = box(fillColor("red"), shrink(0.5));
 	e = ellipse(b, size(200,100), shrink(0.8), lineStyle("dot"));
 	render(higher());
 }
 	
 public bool intInput(str s){
	return /^[0-9]+$/ := s;
}

public Figure higher(){
	int H = 100;
    return vcat( [ textfield("<H>", void(str s){H = toInt(s);}, intInput),
	               box(width(100), vresizable(false), vsize(num(){return H;}), fillColor("red"))
	             ], shrink(0.5), resizable(false));
 }
 */