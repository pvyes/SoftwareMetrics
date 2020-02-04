//gathers information from fields and visualizes this in a node

module ClassFields

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;

import vis::KeySym;

import Visualization; //to reference the onClick function

Color bg_color = color("Gainsboro", 0.3);
alias FieldNodes = lrel[loc definition, Figure fieldBox];
alias FieldInfo = tuple[loc,str,str,set[Modifier]];

/* Returns a relation of locations and Figures presenting basic information of java fields
*/
public FieldNodes makeFieldNodes(M3 model, loc classDefinition) {
	rel[loc definition, str name, str attrType, set[Modifier] modifiers] fields = getFieldsOfClass(model, classDefinition);
	FieldNodes fieldNodes = [<f.definition, makeFieldBox(model,f)> | f <- fields];
	Figure fieldsBox = makeFieldsBox(fieldNodes);
	return fieldNodes;
}

public Figure makeFieldsBox(FieldNodes fieldNodes) {
	list[Figures] fieldBoxes = [[b] | <_,b> <- fieldNodes];	
	Figure fieldsBox = box(grid(fieldBoxes));
	return fieldsBox;
}


/* Returns a Figure presenting basic class/interface information */
public Figure makeFieldBox(M3 model,  tuple[loc definition, str name, str attrType, set[Modifier] modifiers] field) {
	Figure fieldNode;
	//name of field
	str textstr = "<field.name>: <field.attrType>";
	//get modifiers
	set[Modifier] modifiers = field.modifiers;
	bool font_italic = false;
	//set italic for abstract classes
	if (\abstract() in modifiers) font_italic = true;
	str posttext = "";
	if (\final() in modifiers) posttext = "\t{readOnly}";
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
	
	//make fieldNode
	Figure fieldBox = box(
		text("<textstr><posttext>", 
			fontItalic(font_italic), 
			fontBold(font_bold),
			halign(0.05)),  
		id(field.definition.uri), 
		grow(1.2),
		fillColor(bg_color),
		lineColor(bg_color)
	);
//	println(fieldBox);
	return fieldBox;
}

/* renders one node */ 
public void showFieldNode(loc definition) {
 	render(makeNode(definition));
}
 
/* returns a relation of all declarations of java fields.
  <loc definition, loc location>
*/
public rel[loc definition, loc location] getFieldDeclarations(M3 model) {
    return {<x,y> | <x,y> <- model.declarations, x.scheme=="java+field"};
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

/* returns a relation of all the field names.
 	<str name, loc definition>
 	*/
public rel[str name, loc definition] getFieldNames(model) {
    return {<x,y> | <x,y> <- model.names, y.scheme=="java+field"};
}

/* returns the name of a particular java class or interface */
public str getFieldName(M3 model, loc definition) {
 	set[str] name = {x.name | x <- getFieldNames(model), x.definition == definition};
 	if (size(name) > 0) {
 		return getOneFrom(name);
 	}
	return "";
}

/* returns a relation of all the fields.
 	<loc definition, str name, str attrType, set[Modifier] modifiers >
 */
public rel[loc definition, str name, str attrType, set[Modifier] modifiers] getFieldsOfClasses(model) {
	rel[loc definition, Modifier modifier] modifiers = getFieldsModifiers(model);
	rel[loc,str,str,set[Modifier]] fieldinfos = {<x, getFieldName(model , x), getTypeToString(y), getModifiers(modifiers, x)> | <x,y> <- model.types, x.scheme == "java+field"};
	return fieldinfos;
}

/* returns a relation of particular fields of a given class.
 	<loc definition, str name, str attrType, set[Modifier] modifiers >
 */
public rel[loc definition, str name, str attrType, set[Modifier] modifiers] getFieldsOfClass(M3 model, loc definition) {
	rel[loc definition,str name,str attrType,set[Modifier] modifiers] fields = getFieldsOfClasses(model);
	set[loc] fieldsOfClass = {y | <x,y> <- getFieldContainment(model,definition)};
	return {f | f <- fields, f.definition in fieldsOfClass};
}

/* returns a relation of all modifiers of java fields.
  <loc definition, Modifier modifier>
  */ 
public rel[loc definition, Modifier modifier] getFieldsModifiers(model) {
    return  {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+field"};
}
 
 /* returns a set of all modifiers of a defined class, method, field,...
  <loc definition, Modifier modifier>
  */
public set[Modifier] getModifiers(rel[loc definition, Modifier modifier] modifiers, loc definition) {
 	set[Modifier] modifiers = {x.modifier | x <- modifiers, x.definition == definition};
 	return modifiers;
}

/* returns a set of all modifiers of a defined class, method, field,...
  <loc definition, Modifier modifier>
  */
public rel[loc,loc] getFieldContainment(M3 model, loc definition) {
 	rel[loc,loc] containments = {<x,y> | <x,y> <- model.containment, y.scheme == "java+field" && x == definition};
 	return containments;
}

 
/*Returns the type of a TypeSymbol (not exhaustive) as a string. Arrays are colored with an [] after the typename */
public str getTypeToString(TypeSymbol t) {
	switch (t) {
		case \class(loc decl, list[TypeSymbol] typeParameters): {
			return t.decl.file; 
		}
		case \interface(loc decl, list[TypeSymbol] typeParameters): {
			return t.decl.file; 
		}		
		case \array(TypeSymbol component, int dimension): {
			TypeSymbol ts = getNestedTypeSymbol(component);
			return "<ts.decl.file>[]";
		}
		default: {
			return "<t>"; 
		}
	}
}

/* Returns a nested TypeSymbol, e.g. for arrays */
public TypeSymbol getNestedTypeSymbol(TypeSymbol t) {
	switch (t) {
		case \array(TypeSymbol component, int dimension): {
			return getNestedTypeSymbol(component);
		}
		default: {
			return t; 
		}
	}
}