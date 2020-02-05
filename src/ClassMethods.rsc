//gathers information from fields and visualizes this in a node

module ClassMethods

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;

import vis::KeySym;

import Visualization; //to reference the onClick function

Color bg_color = color("Gainsboro", 0.3);
alias MethodNodes = lrel[loc definition, Figure fieldBox];
alias Parameters = rel[loc definition, str name, str paramType];
alias MethodInfos = rel[loc definition, str name, str returntype, Parameters parameters, set[Modifier] modifiers];

/* Returns a relation of locations and Figures presenting information of java methods
*/
public MethodNodes makeMethodNodes(M3 model, loc classDefinition) {
//	rel[loc definition, str name, str returntype, set[Modifier] modifiers] fields = getFieldsOfClass(model, classDefinition);
	MethodInfos methods = getMethodsOfClass(model, classDefinition);
	MethodNodes methodNodes = [<m.definition, makeMethodBox(model,m)> | m <- methods];
	Figure methodsBox = makeMethodsBox(methodNodes);
	return methodNodes;
}

public Figure makeMethodsBox(MethodNodes methodNodes) {
	list[Figures] methodBoxes = [[b] | <_,b> <- methodNodes];	
	Figure methodBox = box(grid(methodBoxes));
	return methodBox;
}


/* Returns a Figure presenting method information */
public Figure makeMethodBox(M3 model,  tuple[loc definition, str name, str returntype, Parameters parameters, set[Modifier] modifiers] method) {
	Figure methodNode;
	//name of method
	str pstring = "(";
	for (<_,pname,ptype> <- method.parameters) {
		if (pstring != "(") pstring += ", ";
		str p = pname + ":" + ptype;
		pstring += p;
	} 
	pstring += ")";
	str textstr = "<method.name><pstring>: <method.returntype>";
	//get modifiers
	set[Modifier] modifiers = method.modifiers;
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
	
	//make methodNode
	Figure methodBox = box(
		text("<textstr><posttext>", 
			fontItalic(font_italic), 
			fontBold(font_bold),
			halign(0.05)),  
		id(method.definition.uri), 
		grow(1.2),
		fillColor(bg_color),
		lineColor(bg_color)
	);
//	println(methodBox);
	return methodBox;
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

/* returns a relation of all the method names.
 	<str name, loc definition>
 	*/
public rel[str name, loc definition] getMethodNames(model) {
    return {<x,y> | <x,y> <- model.names, y.scheme=="java+method"};
}

/* returns the name of a particular java method */
public str getMethodName(M3 model, loc definition) {
 	set[str] name = {x.name | x <- getMethodNames(model), x.definition == definition};
 	if (size(name) > 0) {
 		return getOneFrom(name);
 	}
	return "";
}

/* returns a relation of all the method names.
 	<str name, loc definition>
 	*/
public rel[str,loc] getParameters(model) {
    return {<x,y> | <x,y> <- model.names, y.scheme=="java+parameter"};
}

/* returns the name of a particular java class or interface */
public Parameters getMethodParameters(M3 model, set[loc] paramDefinitions) {
	return {getParameter(model, pdef) | pdef <- paramDefinitions};
}

public tuple[loc definition, str name, str methodType] getParameter(M3 model, loc paramDefinition) {
	set[str] name =  {name | <name,def> <- getParameters(model), def == paramDefinition};
	set[str] ptype = {getTypeToString(y) | <x,y> <- model.types, x.scheme == "java+parameter", x == paramDefinition};
	if (size(name) == 0 && size(ptype) == 0) return <paramDefinition, "", "">;
	if (size(name) == 0) return <paramDefinition, "", getOneFrom(ptype)>;
	if (size(ptype) == 0) return <paramDefinition, getOneFrom(name), "">;
	return <paramDefinition, getOneFrom(name), getOneFrom(ptype)>;
}


/* returns a relation of all the fields.
 	<loc definition, str name, str returntype, set[Modifier] modifiers >
 */
public rel[loc definition, str name, str returntype, Parameters parameters, set[Modifier] modifiers] getMethod(M3 model, loc methodDefinition, set[loc] params) {
	rel[loc definition, loc location] decls =  getMethodDeclarations(model, methodDefinition);
	rel[loc definition, Modifier modifier] modifiers = getMethodsModifiers(model);
	rel[loc definition, str name, str returntype, Parameters parameters, set[Modifier] modifiers] methodinfo = {<x, getMethodName(model , x), getTypeToString(getMethodInfo(y).returnType), getMethodParameters(model, params), getModifiers(modifiers, x)> | <x,y> <- model.types, x.scheme == "java+method", x == methodDefinition};
//println("methodInfo = \n<methodinfo>");
	return methodinfo;
}

public rel[loc definition, loc location] getMethodDeclarations(M3 model, loc definition) {
    return {<x,y> | <x,y> <- model.declarations, x.scheme=="java+method", x == definition};
}


public rel[loc definition, loc location] getParameterDeclarations(M3 model/*, loc definition*/) {
    return {<x,y> | <x,y> <- model.declarations, x.scheme=="java+parameter"/*, x == definition*/};
}

/* returns a relation of particular fields of a given class.
 	<loc definition, str name, str returntype, set[Modifier] modifiers >
 */
public MethodInfos getMethodsOfClass(M3 model, loc classDefinition) {
	MethodInfos methodInfos = {};
	for (<_,methodDefinition> <- getMethodContainment(model, classDefinition)) {
		set[loc parameter] params = {y | <_,y> <- getParameterContainment(model, methodDefinition)};
		methodInfos += getMethod(model, methodDefinition, params);
	}
	return methodInfos;
}

/* returns a relation of all modifiers of java fields.
  <loc definition, Modifier modifier>
  */ 
public rel[loc definition, Modifier modifier] getMethodsModifiers(model) {
    return  {<x,y> | <x,y> <- model.modifiers, x.scheme=="java+method"};
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
public rel[loc,loc] getMethodContainment(M3 model, loc definition) {
 	rel[loc,loc] containments = {<x,y> | <x,y> <- model.containment, y.scheme == "java+method" && x == definition};
 	return containments;
}

public rel[loc method,loc parameter] getParameterContainment(M3 model, loc definition) {
 	rel[loc,loc] containments = {<x,y> | <x,y> <- model.containment, y.scheme == "java+parameter" && x == definition};
 	return containments;
}
 
/*Returns the type of a TypeSymbol (not exhaustive) as a string. Arrays are colored with an [] after the typename */
public tuple[loc decl, list[TypeSymbol] typeParameters, TypeSymbol returnType, list[TypeSymbol] parameters]  getMethodInfo(TypeSymbol t) {
	tuple[loc decl, list[TypeSymbol] typeParameters, TypeSymbol returnType, list[TypeSymbol] parameters] info;
	switch (t) {
		case \method(loc decl, list[TypeSymbol] typeParameters, TypeSymbol returnType, list[TypeSymbol] parameters): {
			info = <decl,typeParameters, returnType, parameters>; 
			return info;
		}
		default: return t; 
	}
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
			return "<ts>[]";
//			return "<ts.decl.file>[]";
		}
		default: {
			return "<t>"; 
		}
	}
}

/* Returns a nested TypeSymbol, e.g. for arrays */
public TypeSymbol getNestedTypeSymbol(TypeSymbol t) {
	switch (t) {
		case \class(loc decl, list[TypeSymbol] typeParameters): {
			return t; 
		}
		case \array(TypeSymbol component, int dimension): {
			return getNestedTypeSymbol(component);
		}
		default: {
			return \unresolved(); 
		}
	}
}