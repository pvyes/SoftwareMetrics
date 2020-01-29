//gathers information from classes and interfaces and visualizes this in a node

module ClassNodes

import Prelude;
import lang::java::jdt::m3::Core;
import vis::Figure;

public void getClassInformation(/M3 model*/) {
	loc project = |project://Jabberpoint|;
    M3 model = createM3FromEclipseProject(project);

}

public rel[loc definition, Modifier modifier] getClassesModifiers() {
	loc project = |project://Jabberpoint2|;
    M3 model = createM3FromEclipseProject(project);
    rel[loc definition, Modifier modifier] modifiers = {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+class" || x.scheme=="java+interface"};
    println("#classes = <size(modifiers)>");
    return modifiers;
 }
 
 public set[Modifier] getClassModifiers(loc definition) {
   	rel[loc definition, Modifier modifier] modifiers = getClassesModifiers();
 	set[Modifier] classModifiers = {x.modifier | x <- modifiers, x.definition == definition};
 	return classModifiers;
 }
 
 
 //returns all the classnames, also classnames of dependencies (e.g. java/lang; java/util, java/io,...)
 public rel[str name, loc definition] getClassNames() {
	loc project = |project://Jabberpoint2|;
    M3 model = createM3FromEclipseProject(project);
    rel[str name, loc definition] classNames = {<x,y> | <x,y> <- model.names, y.scheme=="java+class" || y.scheme=="java+interface"};
    println("#classes = <size(classNames)>");
    return classNames;
 }
 
 public str getClassName(loc definition) {
 	rel[str name, loc definition] classnames = getClassNames();
 	set[str] name = {x.name | x <- classnames, x.definition == definition};
 	return getOneFrom(name);
 } 
 
 public rel[loc definition, loc location] getDeclarations() {
	loc project = |project://Jabberpoint2|;
    M3 model = createM3FromEclipseProject(project);
    rel[loc definition, loc location] classDeclarations = {<x,y> | <x,y> <- model.declarations, x.scheme=="java+class" || x.scheme=="java+interface"};
    println("#classDeclarations = <size(classDeclarations)>");
    return classDeclarations;
 }
 
 public Figure makeNode(loc definition) {
	Figure classNode;
	//general backgroundcolor
	str bg_color = "Gainsboro";
	//name of class
	str name = getClassName(definition);
	//get modifiers
	set[Modifiers] modifiers = getClassModifiers(definition);
	//set style for abstract classes
	//add text <<interface>> for interfaces
	
	//make classNode
	
	
	return classNode;
 }
