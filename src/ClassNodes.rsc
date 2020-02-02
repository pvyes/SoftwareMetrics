//gathers information from classes and interfaces and visualizes this in a node

module ClassNodes

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;

import vis::KeySym;

import ClassEdges;
import Visualization; //to reference the onClick function

Color bg_color = color("Gainsboro", 0.3);
alias ClassNodes = lrel[loc definition, Figure classBox];

/* Returns a relation of locations and Figures presenting basic information of java classes and interfaces
*/
public ClassNodes makeClassNodes(M3 model) {
	set[loc] classDefinitions =  { l | <l,_> <- getClassAndInterfaceDeclarations(model)};
	ClassNodes nodes = [< n, makeClassBox(model, n)> | n <- classDefinitions];
	return nodes;
}

/* Returns a Figure presenting basic class/interface information */
public Figure makeClassBox(M3 model, loc definition) {
	Figure classNode;
	//name of class
	str name = getClassName(getClassNames(model), definition);
	//get modifiers
	set[Modifier] modifiers = getClassModifiers(model, definition);
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
	if (\static() in modifiers) font_bold = true;	
	//find color for visibility
	Modifier modifier;
	set[Modifier] visibilities = {m | m <- modifiers, m == \public() || m == \protected() || m == \private()};
	if (size(visibilities) > 0)  {
		modifier = getOneFrom(visibilities);
		bg_color = getModifierColor(modifier);
	}
	
	//make classNode
	Figure classBox = box(
		text("<pretext><name><posttext>", 
			fontItalic(font_italic), 
			fontBold(font_bold), 
			justify(true)), 
			id(definition.uri), 
		grow(1.2), 
		fillColor(bg_color),
		onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
			showClassDetails(definition);
			return true;
			})
		);
	return classBox;
}

/* renders one class node */ 
public void showClassNode(loc definition) {
 	render(makeNode(definition));
}
 
/* returns a relation of all declarations of java classes and interfaces.
  <loc definition, loc location>
  */
public rel[loc definition, loc location] getClassAndInterfaceDeclarations(M3 model) {
    return {<x,y> | <x,y> <- model.declarations, x.scheme=="java+class" || x.scheme=="java+interface"};
}
 
 /* returns the color for visibility property */
public Color getModifierColor(Modifier m) {
  	switch (m)  {
 		case \public(): return color("MediumSeaGreen",0.3);
 		case \protected(): return color("Coral",0.3);
 		case \private(): return color("Crimson",0.3);
 		default: return bg_color;
 	}
}
 
/* returns a relation of all modifiers of java classes and interfaces.
  <loc definition, Modifier modifier>
  */ 
public rel[loc definition, Modifier modifier] getClassesModifiers(model) {
    return  {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+class" || x.scheme=="java+interface"};
}
 
 /* returns a set of all modifiers of a particular class.
  <loc definition, Modifier modifier>
  */
public set[Modifier] getClassModifiers(M3 model, loc definition) {
   	rel[loc definition, Modifier modifier] modifiers = getClassesModifiers(model);
 	set[Modifier] classModifiers = {x.modifier | x <- modifiers, x.definition == definition};
 	return classModifiers;
}
 
/* returns a relation of all the class- and interface names, also classnames of dependencies (e.g. java/lang; java/util, java/io,...).
 	<str name, loc definition>
 	*/
public rel[str name, loc definition] getClassNames(model) {
    return {<x,y> | <x,y> <- model.names, y.scheme=="java+class" || y.scheme=="java+interface"};
}

/* returns a relation of all the field names.
 	<str name, loc definition>
 	*/
public rel[str name, loc definition] getFieldNames(model) {
    return {<x,y> | <x,y> <- model.names, y.scheme=="java+field"};
}

/* returns the name of a particular java class or interface */
public str getClassName(rel[str name, loc definition] classnames, loc definition) {
 	set[str] name = {x.name | x <- classnames, x.definition == definition};
 	if (size(name) > 0) {
 		return getOneFrom(name);
 	}
	return "";
}

/* returns a relation of all the class- and interface fields, also classnames of dependencies (e.g. java/lang; java/util, java/io,...).
 	<loc definition, str type, set[Modifier] >
 */
public rel[loc definition, str class, set[Modifier] modifiers] getClassFields(model) {
	rel[loc definition, Modifier modifier] modifiers = getFieldsModifiers(model);
	return {<x,getTypeToString(y),getModifiers(modifiers, x)> | <x,y> <- model.types, x.scheme == "java+field"};
}