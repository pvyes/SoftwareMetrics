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
import ClassMethods;
import Volumes;
import Complexities;
import Data;
import Analytics;

alias MethodMetrics = lrel[loc definition, int linesOfCode, int complexity];

loc project;
M3 model;
ClassNodes classNodes;
Color bg_color = color("Gainsboro");

public void initializeVisualization(M3 m, loc p) {
	model = m;
	project = p;
	classNodes = makeClassNodes(model);
	Figure container = box(makeMenu(), id("container"), vshrink(0.2));
	render(container);
}

public Figure makeMenu() {
	Figure btnGraph = button("All Classes", void() {showBasicClassGraph();});
	map[str,loc] classNames = (c.name : c.definition | c <- getClassNames(model));
	Figure comboClasses = combo(sort([c.name | c <- getClassNames(model)]), void(str className) { showClassDetails(classNames[className]);}); 
	Figure btnMetrics = button("Show metrics", void() {showMetrics(model);});
	Figure choiceView = choice(["Grid", "Graph"], void(str view) {setView(view);});
	
	return hcat([btnGraph,comboClasses,btnMetrics, choiceView], gap(10));
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
 	// replace main node by its detailed box
 	Figure centralClass = makeDetailedClassNode(model, definition);
// 	render(centralClass);
	classNodes = makeClassNodes(model); 	
	// filter classnodes
 	Figures classBoxes = toList({replaceCentralClass(cn.classBox, cn.definition, definition, centralClass) | cn <- classNodes, r <- relations, cn.definition == r.child || cn.definition == r.parent}); 

	showGraph(classBoxes, classEdges);
}

public Figure replaceCentralClass(Figure classbox, loc currentDefinition, loc centralDefinition, Figure centralClass) {
	if (currentDefinition == centralDefinition) return centralClass;
	return classbox;
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
	
public void showMethodNodes(/*model, classDefinition*/) {
	loc PROJECT = |project://Jabberpoint2|;
	M3 model = createM3FromEclipseProject(PROJECT); 
	Figures methodboxes = [b | <l,b> <- makeMethodNodes(model/*, classDefinition*/)];
	render(makeMethodsBox(makeMethodNodes(model/*, classDefinition*/)));	
}

/* gather all classinformation (name, attributes, methods) in one classBox */
public Figure makeDetailedClassNode(M3 model, loc classDefinition) {
	Figure nameBox = makeClassBox(model, classDefinition);
	FieldNodes fieldNodes = makeFieldNodes(model, classDefinition);
	int nrOfFields = size(fieldNodes);
	Figure fieldBox = makeFieldsBox(fieldNodes);
	MethodNodes methodNodes = makeMethodNodes(model, classDefinition);
	int nrOfMethods = size(methodNodes);
	Figure methodBox = makeMethodsBox(methodNodes);

	//calculate heights
	real rows = toReal(3 + nrOfFields + nrOfMethods);
	real unit = 1/rows * 1.000;
//	println("rows = <rows>, unit = <unit>");
	nameBox = box(nameBox, vshrink(2 * unit), lineWidth(4));
	fieldBox = box(fieldBox, vshrink(nrOfFields * unit), lineWidth(4));
	methodBox = box(methodBox, vshrink(nrOfMethods * unit), lineWidth(4));
//render(grid([[nameBox],[fieldBox],[methodBox]], id(classDefinition.uri)));
	return grid([[nameBox],[fieldBox],[methodBox]], id(classDefinition.uri));
}

/*
public rel[tuple[str,int,int] rank, set[FileLineInformation] flis] getMethodVolumeMetrics(M3 model) {
	classNodes = makeClassNodes(model);
	set[FileLineInformation] flis = countLinesOfCodePerMethod(model);

	rel[tuple[str,int,int] rank, set[FileLineInformation] flis] methodsPerRisk = {};
	for (r <- getLinesOfJavaCodeMethodsRanking()) {
		set[FileLineInformation] flisPerRisk = gatherMethodsByRisk(flis, r.rank);
	print("risk");println(size(flisPerRisk));
		methodsPerRisk += {<r, flisPerRisk>};
	}
	return methodsPerRisk;
}

public void showVolumeMetrics() {
	rel[tuple[str,int,int] rank, set[FileLineInformation] flis] vMetrics = getMethodVolumeMetrics();
	list[Figures] vBoxes = [];
	vBoxes = ([makeVBlocks(vm) | vm <- vMetrics]);
	Figures boxes = [b | vb <- vBoxes, b <- vb];
	println("#boxes = <size(boxes)>");
	render(pack(boxes));	
}
	
public Figures makeVBlocks(tuple[tuple[str rank,int min ,int max] rank, set[FileLineInformation] flis] vm) {
	Color lColor = getRiskColor(vm.rank.rank);
	int lWidth = 4;	
	return [box(text("LOC: " + toString(fli.linesOfCode)),id(fli.fileLocation.uri), lineColor(lColor), lineWidth(lWidth), size(calculateSize(fli.linesOfCode))) | fli <- vm.flis];
}

public rel[tuple[str,int,int] rank, set[ComplexityInformation] cis] getMethodComplexityMetrics(M3 model) {
	classNodes = makeClassNodes(model);
	set[ComplexityInformation] cis = calculateComplexities(PROJECT);

	rel[tuple[str risk,int min,int max] rank, set[ComplexityInformation] cis] methodsPerComplexityRisk = {};
	for (r <- getCCRiskEvaluation()) {
		set[ComplexityInformation] cisPerRisk = gatherComplexitiesByRisk(cis, r.risk);
	print("risk");println(size(cisPerRisk));
		methodsPerComplexityRisk += {<r, cisPerRisk>};
	}
	return methodsPerComplexityRisk;
}

public void showComplexityMetrics() {
	rel[tuple[str,int,int] rank, set[ComplexityInformation] cis] cMetrics = getMethodComplexityMetrics();
	list[Figures] cBoxes = [];
	cBoxes = ([makeCBlocks(cm) | cm <- cMetrics]);
	Figures boxes = [b | cb <- cBoxes, b <- cb];
	println("#boxes = <size(boxes)>");
	render(pack(boxes));	
}
*/
public void showMetrics() {
	MethodMetrics methodMetrics = getMethodMetrics();
	Figures mBoxes = ([makeMBlock(mm) | mm <- methodMetrics]);
	println("#boxes = <size(mBoxes)>");
	render(pack(mBoxes, std(gap(5))));	
}

public Figure makeMBlock(mm) {
	Color lColor = getLocRiskColor(mm.linesOfCode);
//println("<mm.linesOfCode> = <lColor>");
	Color fColor = getComplexityRiskColor(mm.complexity);
	int lWidth = 4;
	return box(text("LOC: " + toString(mm.linesOfCode) + "\ncompl: " + toString(mm.complexity), grow(1.2)), 
		id(mm.definition.uri), 
		lineColor(lColor), 
		lineWidth(lWidth), 
		fillColor (fColor), 
		size(calculateSize(mm.linesOfCode)));
}

/*
public Figures makeCBlocks(tuple[loc definition, int linesOfCode, int complexity] mm) {
	Color lColor = getRiskColor(cm.rank.rank);
	int lWidth = 2;	
	return [box(text("compl: " + toString(ci.complexity)),id(ci.name), fillColor(lColor), lineWidth(lWidth)) | ci <- cm.cis];
}
*/
public Color getLocRiskColor(int linesOfCode) {	
  	switch (getVolumeRating(linesOfCode)) {
 		case "low": return color("MediumSeaGreen");
 		case "moderate": return color("Coral");
 		case "high": return color("Crimson");
 		case "very high": return color("DarkRed");
 		default: return color("Black");
 	}
}

public str getVolumeRating(int volume) {
	LinesOfJavaCodeRanking locrs = getLinesOfJavaCodeMethodsRanking();
	str rating = locrs[3].rank;
	for (int i <- [3..-1]) {
		if (volume <= locrs[i].max) { 
			rating = locrs[i].rank;
		}
	}
//	println("volume <volume> = <rating>");
	return rating;
}

public Color getComplexityRiskColor(int compl) {	
  	switch (getComplexityRating(compl)) {
 		case "low": return color("MediumSeaGreen");
 		case "moderate": return color("Coral");
 		case "high": return color("Crimson");
 		case "very high": return color("DarkRed");
 		default: return bg_color;
 	}
}

public str getComplexityRating(int compl) {
	if (compl == -1) return "No rating";
	ComplexityRating crs = getComplexityRanking();
	str rating = crs[3].risk;
	for (int i <- [3..-1]) {
		if (compl <= crs[i].max) { 
			rating = crs[i].risk;
		}
	}
	return rating;
}



public Color getRiskColor(str risk) {
  	switch (risk)  {
 		case "low": return color("MediumSeaGreen");
 		case "moderate": return color("Coral");
 		case "high": return color("Crimson");
 		case "very high": return color("DarkRed");
 		default: return bg_color;
 	}
}
 
public real calculateSize(int nrOfLines) {
	return nrOfLines * 1.0;
}

public MethodMetrics getMethodMetrics() {
	set[loc] classDefinitions =  { l | <l,_> <- getClassAndInterfaceDeclarations(model)};
	MethodInfos methods = {};
	set[ComplexityInformation] cis = calculateComplexities(project);
	for (classDefinition <- classDefinitions) {
		methods += getMethodsOfClass(model, classDefinition);
	}
	MethodMetrics methodMetrics = [<m.definition, getLinesOfCode(m.definition), getComplexity(m.definition, m.name, cis)> | m <- methods];
	return methodMetrics;
}

public int getLinesOfCode(loc methodDefinition) {
	FileLineInformation fli = countLinesOfCodeOfMethod(methodDefinition);
	return fli.linesOfCode;
}

public int getComplexity(loc methodDefinition, str methodName, set[ComplexityInformation] cis) {
	loc PROJECT = |project://Jabberpoint2|;
	M3 model = createM3FromEclipseProject(PROJECT);
	set[loc] projectdecl = {y | <x,y> <- model.declarations, x.scheme=="java+method", x.path == methodDefinition.path};
	set[int] compls = {compl | <decl,name,compl> <- cis, decl.path == getOneFrom(projectdecl).path && name == methodName};
	if (size(compls) == 0) return -1;
	return getOneFrom(compls);
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