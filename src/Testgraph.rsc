module Testgraph

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import analysis::graphs::Graph;
import Relation;
import vis::Figure;
import vis::Render;
import util::Math;

public Figure showGraph(Graph[loc] g) {
   nodes = [ box(text(s.file), id(s.uri), size(60), fillColor("yellow"))
           | s <- carrier(g) 
           ];
   edges = [ edge(a.uri, b.uri, toArrow(ellipse(size(5))))
           | <a, b> <- g
           ];
   return graph(nodes, edges, hint("layered"), gap(50));
}

public void showExtends() {
	Graph g = getClassExtends();
	render(showGraph(g));
}

//first is the extended class (higher in hierarchy); second is class which extends
public rel[loc,loc] getClassExtends() {
	loc project = |project://Jabberpoint|;
	M3 model = createM3FromEclipseProject(project); 
    rel[loc,loc] classes =  { <y,x> | <x,y> <- model.extends};	
	return classes;
}

public rel[loc,loc] getClasses() {
	loc project = |project://Jabberpoint|;
    M3 model = createM3FromEclipseProject(project); 
    rel[loc name,loc location] classes =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+class"};
    return classes;
}

public rel[loc definition, Modifier modifier] getClassModifiers() {
	loc project = |project://Jabberpoint|;
    M3 model = createM3FromEclipseProject(project);
    rel[loc definition, Modifier modifier] modifiers = {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+class"};
    println("#classes = <size(modifiers)>");
    return modifiers;
 }
 
public Figures getModifierNodes() {
	return (makeModifierNodes(getClassModifiers()));
}
 
public Figures makeModifierNodes(rel[loc definition, Modifier modifier] modifiers) {
	Figures nodes = [];
	for (m <- modifiers) {
		str t = m.definition.file;
		str color = getModifierColor(m.modifier);
		str uid = m.definition.file;
		Figure b = box(text(t), id(uid), size(60), fillColor(color));
		nodes += b;
	}	
	return nodes;
 }
 
 public str getModifierColor(Modifier m) {
  	switch (m)  {
 		case \public(): return "red";
 		case \abstract(): return "green";
 		default: return "white";
 	}
 	return "white";
 }

//places a number of figures in a grid
//public void placeFigures(Figure container, Figures figures) {
public void placeFigures() {
	Figures nodes = getModifierNodes();
	list[Figures] rows = [];
	int nrOfColumns = 5;
	int nrOfRows = 4;
	
	int i = 0;
	Figures row = [];
	for (f <- nodes) {
//println("i = <i>; rat = <toRat(i, nrOfColumns)>; remainder = <remainder(toRat(i, nrOfColumns))>");
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
/*	
	int size = size(nodes);
	int nrOfColumns = 5;
	int nrOfRows = 4;
	real margin = 0.02;
	//calculations
	real remHor = 1 - (nrOfColumns + 1) * margin;
	real remVert = 1 - (nrOfRows + 1) * margin ;
	int w = toInt(remHor / nrOfColumns);
	int h = toInt(remVert / nrOfRows);
	
	figures += container;	
	int i = 0;
	for (f <- nodes) {
		newF = computeFigure(f, width(w), height(h), halign(margin + w * remainder(toRat(i, nrOfColumns))), valign(margin + w * remainder(toRat(i, nrOfRows))));
//		f.properties.width(w);
//		f.height(h);
//		f.halign(margin + w * remainder(toRat(i / nrOfColumns)));
//		f.valign(margin + w * remainder(toRat(i / nrOfRows)));
		i++;
		figures += f;
	}
	render(overlay(figures));
*/
}