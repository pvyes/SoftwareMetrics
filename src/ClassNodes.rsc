//gathers information from classes and interfaces and visualizes this in a node

module ClassNodes

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import util::Math;

Color bg_color = color("Gainsboro", 0.3);
loc project = |project://smallsql|;
M3 model = createM3FromEclipseProject(project);

public void showClassInformation(/*M3 model*/) {
//	loc project = |project://Jabberpoint|;
//    M3 model = createM3FromEclipseProject(project);
	set[loc] classDefinitions =  { l | <l,_> <- getDeclarations()};
	Figures nodes = [makeNode(n) | n <- classDefinitions];
	
	//render in grid
	list[Figures] rows = [];
	int nrOfColumns = 10;
	int nrOfRows = 20;
	
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
}

public rel[loc definition, Modifier modifier] getClassesModifiers() {
//	loc project = |project://Jabberpoint2|;
//    M3 model = createM3FromEclipseProject(project);
    rel[loc definition, Modifier modifier] modifiers = {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+class" || x.scheme=="java+interface"};
//    println("#classmodifiers = <size(modifiers)>");
    return modifiers;
 }
 
 public set[Modifier] getClassModifiers(loc definition) {
   	rel[loc definition, Modifier modifier] modifiers = getClassesModifiers();
 	set[Modifier] classModifiers = {x.modifier | x <- modifiers, x.definition == definition};
 	return classModifiers;
 }
 
 
 //returns all the classnames, also classnames of dependencies (e.g. java/lang; java/util, java/io,...)
 public rel[str name, loc definition] getClassNames() {
//	loc project = |project://Jabberpoint2|;
//    M3 model = createM3FromEclipseProject(project);
    rel[str name, loc definition] classNames = {<x,y> | <x,y> <- model.names, y.scheme=="java+class" || y.scheme=="java+interface"};
//    println("#classes = <size(classNames)>");
    return classNames;
 }
 
 public str getClassName(loc definition) {
 	rel[str name, loc definition] classnames = getClassNames();
 	set[str] name = {x.name | x <- classnames, x.definition == definition};
 	if (size(name) > 0) {
 		return getOneFrom(name);
 	}
	return "";
 } 
 
 public rel[loc definition, loc location] getDeclarations() {
//	loc project = |project://Jabberpoint2|;
//    M3 model = createM3FromEclipseProject(project);
    rel[loc definition, loc location] classDeclarations = {<x,y> | <x,y> <- model.declarations, x.scheme=="java+class" || x.scheme=="java+interface"};
    println("#classDeclarations = <size(classDeclarations)>");
    return classDeclarations;
 }
 
 public Figure makeNode(loc definition) {
	Figure classNode;
	//name of class
	str name = getClassName(definition);
println(name);
	//get modifiers
	set[Modifier] modifiers = getClassModifiers(definition);
	bool font_italic = false;
	//set italic for abstract classes
	if (\abstract() in modifiers) font_italic = true;
	//add text <<interface>> for interfaces
	str pretext = "";
	if (definition.scheme == "java+interface") pretext = "\<\<interface\>\>\n";
	//add text {leaf} for final classes
	str posttext = "";
	if (\final() in modifiers) posttext = "\t{leaf}";
	//set bold for static classes
	bool font_bold = false;
	if (\static() in modifiers) font_bold = true;;
	
	//find color for visibility
	Modifier modifier;
	set[Modifier] visibilities = {m | m <- modifiers, m == \public() || m == \protected() || m == \private()};
	if (size(visibilities) > 0)  {
		modifier = getOneFrom({m | m <- visibilities, m == \public() || m == \protected() || m == \private()});
		bg_color = getModifierColor(modifier);
	}	//make classNode
	Figure classNameBox = box(text("<pretext><name><posttext>", fontItalic(font_italic), fontBold(font_bold), justify(true)), fillColor(bg_color)); 
	return classNameBox;
 }
 
 public void showClassNode(loc definition) {
 	render(makeNode(definition));
 }
 
  public Color getModifierColor(Modifier m) {
  	switch (m)  {
 		case \public(): return color("MediumSeaGreen",0.3);
 		case \protected(): return color("Coral",0.3);
 		case \private(): return color("Crimson",0.3);
 		default: return bg_color;
 	}
 }
