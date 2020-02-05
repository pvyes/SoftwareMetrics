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
import Duplication;

alias MethodMetrics = lrel[loc definition, int linesOfCode, int complexity];

set[FileLineInformation] flis;
set[ComplexityInformation] cis;
loc project;
M3 model;
ClassNodes classNodes;
MethodMetrics methodMetrics;

Color bg_color = color("Gainsboro");
Color menu_color = color("Silver");
Color column_color = color("Gray");
Figure mainArea;
Figure leftColumn;
Figure menu;

Color transparent = color("white",0.0);
Figure mainContent = box(id("mainContent"), fillColor(transparent));
Figure leftContent = box(id("leftContent"), fillColor(transparent));
Figure menuContent = box(id("menuContent"), fillColor(transparent));

public void initializeVisualization(M3 m, loc p) {
	model = m;
	project = p;
	flis = countLinesOfCodePerMethod(model);
	cis = calculateComplexities(project);

	classNodes = makeClassNodes(model);
	methodMetrics = getMethodMetrics();
	leftContent = makeMenu();
	showBasicClassGraph();
}

public void show() {
	render(getMainFigure());
}

public Figure getMainFigure() {
	leftColumn = box(getLeftContent(), id("leftColumn"), fillColor(column_color), left(), hshrink(0.20));
	mainArea = box(getMainContent(), id("mainArea"), fillColor(bg_color),right(), hshrink(0.75));
	Figure bottom = grid([[leftColumn, mainArea]]);
	Figure container = overlay([bottom]);
	return container;
}

public Figure getMenuContent() {
	return menuContent;
}

public Figure getLeftContent() {
	return leftContent;
}

public Figure getMainContent() {
	return mainContent;
}

public Figure makeMenu() {
	map[str,loc] classNames = (c.name : c.definition | c <- getClassNames(model));
	Figure comboClasses = combo(sort([c.name | c <- getClassNames(model)]), void(str className) { showClassDetails(classNames[className]);}, fillColor(transparent)); 
	Figure btnGraph = button("Show classes", void() {showBasicClassGraph();});
	Figure btnMethods = button("Show methods", void() {showMethods();});
	Figure btnMetrics = button("Show metrics", void() {showMetricInformation();});
	Figure choiceView = choice(["Grid", "Graph"], void(str view) {setView(view);});
	return vcat([comboClasses, btnGraph, btnMethods, btnMetrics, choiceView], gap(2), vshrink(0.25), top());
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

public void setView(str view) {

}

public void showClassDetails(loc definition) {
 	println("mouse clicked on <definition>");
 	set[Relation] relations = gatherClassRelations(model);
 	//filter relations
 	relations = {r | r <- relations, r.child == definition || r.parent == definition};	
 	list[Edge] classEdges = makeClassEdges(relations);
 	// replace main node by its detailed box
 	Figure centralClass = makeDetailedClassNode(model, definition);
	classNodes = makeClassNodes(model); 	
	// filter classnodes
 	Figures classBoxes = toList({replaceCentralClass(cn.classBox, cn.definition, definition, centralClass) | cn <- classNodes, r <- relations, cn.definition == r.child || cn.definition == r.parent}); 
	Figure myGraph = graph(classNodes, classEdges, hint("layered"), gap(50));
	//title
	tit = text("Project: <project.uri>", fontBold(true), fontSize(14));	

	leftContent = vcat([tit, makeMenu()]);
	mainContent = myGraph;
	show();
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


public void showMethods() {
	//mainArea
	Figures mBoxes = ([makeMBlock(mm) | mm <- methodMetrics]);
	mainContent = pack(mBoxes, std(gap(5)), shrink(0.95));
	
	//title
	tit = text("Project: <project.uri>", fontBold(true), fontSize(14));	
	//legenda
	t0 = text("Legenda", fontBold(true), left()); 
	//rankingcolors
	t1 = text("Colors indicating Risk:\n");
	t2a = text("Low", left(), fontSize(11)); t2b = box(fillColor("MediumSeaGreen"));
	t2 = [t2a,t2b];
	t3a = text("Moderate", left(), fontSize(11)); t3b = box(fillColor("Coral"));
	t3 = [t3a,t3b];
	t4a = text("High", left(), fontSize(11)); t4b = box(fillColor("Crimson"));
	t4 = [t4a,t4b];
	t5a = text("Very high", left(), fontSize(11)); t5b = box(fillColor("DarkRed"));
	t5 = [t5a,t5b];
	t6a = text("Not evaluated", left(), fontSize(11)); t6b = box(fillColor(bg_color));
	t6 = [t6a,t6b];
	line = text("line", fontColor(transparent));
	t7a = text("Bordercolor = UnitSize Risk", left(), fontSize(11));
	t7b = text("Backgroundcolor = Complexity Risk", left(), fontSize(11));
	
	Figure rankingColors = box(grid([[t0],[line],[t1],t2,t3,t4,t5,t6]), vshrink(0.2), fillColor(menu_color));
	Figure explanation = box(grid([[t7a],[t7b]]), vshrink(0.06), fillColor(transparent), left());
	
	//volume information
	int volume = getTotalVolume(flis);
	int hsiz = getHighestVolumeFile(flis);
	int lsiz = getLowestVolumeFile(flis);
	int hnrOfMethods = size(getMethodsWithHighestVolume(flis));
	int lnrOfMethods = size(getMethodsWithLowestVolume(flis));
	real med = getMedianVolumeFile(flis);
	int mnrOfMethods = size(getMethodsWithMedianVolume(flis));
	str volumeInfo = "VOLUME INFORMATION" + "\n" + 
		"Number of methods = " + toString(size(flis)) + "\n" +
		"Total methodvolume (Lines of code) = " + toString(volume) + "\n" +
		"Ranking for the total volume of this Java system = " + rankTotalVolume(volume); 
	vi = box(text(volumeInfo, fontSize(11)), left(), fillColor(column_color), left());
	
	//complexityinformation
	set[tuple[str,int,int]] locPerRisk = getLinesOfCodePerRisk(cis,flis);
	set[tuple[str,int,real]] percPerRisk = {<a,b,c> | <a,b,_,c> <- getPercentageOfLinesOfCodePerRisk(cis,flis)};
	map[str,real] percPerRiskMap = (risk : perc | <risk,_,perc> <- percPerRisk);
	str systemRating = rateSystemComplexity(percPerRiskMap);

	str complInfo = "COMPLEXITY INFORMATION" + "\n" +
		"System global complexity ranking = <systemRating>";
	ci = box(text(complInfo, fontSize(11), left()), fillColor(menu_color), left());
	
	//Unit size information
	set[tuple[str,int,int]] mpusr = getMethodsPerUnitSizeRank(flis);
	set[tuple[str,int,int,real]] plocr = getPercentageOfLinesOfCodePerRisk (flis);
	map[str,real] prm = (risk : perc | <risk,_,perc> <- percPerRisk);
	str sr = rateSystemUnitsize(prm);

	str unitInfo = "UNITSIZE INFORMATION" + 
		"System global unit size ranking = <sr>";
	ui = box(text(unitInfo, fontSize(11), left()), fillColor(column_color), left());
	
	//Duplication information
	set[loc] methodLocations = {methodLocation | <methodLocation,_,_,_,_,_> <- flis};
	int numberOfDuplications = getCodeDuplicationInformation(toList(methodLocations));
	real duplicationRate = getDuplicationPercentage(numberOfDuplications, volume);

	str duplInfo = "CODE DUPLICATION" + "\n" +	
		"Duplication Rank: <rankDuplication(duplicationRate)>";
	di = box(text(duplInfo, fontSize(11), left()), fillColor(menu_color), left());
	
			
//	leftContent = box(vcat([t1, hcat([t2a, t2b]), hcat([t3a,t3b]), hcat([t4a,t4b]), hcat([t5a,t5b]), hcat([t6a,t6b]) ]));
	leftContent = vcat([tit, makeMenu(), rankingColors, explanation, vi, ci, ui, di], gap(10), shrink(0.95));
	show();	
}

public void showMetricInformation() {
	//title
	tit = text("Project: <project.uri>", fontBold(true), fontSize(14));	

	//volume information
	int volume = getTotalVolume(flis);
	int hsiz = getHighestVolumeFile(flis);
	int lsiz = getLowestVolumeFile(flis);
	int hnrOfMethods = size(getMethodsWithHighestVolume(flis));
	int lnrOfMethods = size(getMethodsWithLowestVolume(flis));
	real med = getMedianVolumeFile(flis);
	int mnrOfMethods = size(getMethodsWithMedianVolume(flis));
	str volumeInfo = "VOLUME INFORMATION" + "\n" + 
		"Number of methods = " + toString(size(flis)) + "\n" +
		"Lines of code of methods\n(excluding blank lines, comments and documentation)" + "\n" + "\n" +
		"Total methodvolume = " + toString(volume) + "\n" +
		"Ranking for the total volume of this Java system = " + rankTotalVolume(volume)  + "\n" + "\n" + 
		"Highest methodvolume = <hsiz> (<hnrOfMethods> method(s))" + "\n" +
		"Lowest methodvolume = <lsiz> (<lnrOfMethods> method(s))" + "\n" +
		"Average methodvolume = " + toString(toInt(getAverageVolumeFile(flis))) + "\n" +
		"Median methodvolume  = " + toString(med) + " (<mnrOfMethods> method(s))";
	vi = box(text(volumeInfo, fontSize(11)), left(), fillColor(column_color), left());
	
	//complexityinformation
	set[tuple[str,int,int]] locPerRisk = getLinesOfCodePerRisk(cis,flis);
	set[tuple[str,int,real]] percPerRisk = {<a,b,c> | <a,b,_,c> <- getPercentageOfLinesOfCodePerRisk(cis,flis)};
	map[str,real] percPerRiskMap = (risk : perc | <risk,_,perc> <- percPerRisk);
	str systemRating = rateSystemComplexity(percPerRiskMap);

	str complInfo = "COMPLEXITY INFORMATION" + "\n" +
		"Lines of code per risk (absolute)\n(riskname, number of methods, lines of codes):\n<locPerRisk>" + "\n" +
		"Lines of code per risk (percentage)\n(riskname, lines of codes, the percentage):\n<percPerRisk>" + "\n" + "\n" +
		"System global complexity ranking = <systemRating>";
	ci = box(text(complInfo, fontSize(11), left()), fillColor(menu_color), left());
	
	//Unit size information
	set[tuple[str,int,int]] mpusr = getMethodsPerUnitSizeRank(flis);
	set[tuple[str,int,int,real]] plocr = getPercentageOfLinesOfCodePerRisk (flis);
	map[str,real] prm = (risk : perc | <risk,_,perc> <- percPerRisk);
	str sr = rateSystemUnitsize(prm);

	str unitInfo = "UNITSIZE INFORMATION" + 
		"Risks for unit sizes\n(riskname, number of methods, linesOfCode):\n<mpusr>" + "\n" +
		"Risks for unit sizes in percentages\n(riskname, lines of Code, totalVolume, percentage of linesOfCode):\n<plocr>" + "\n" +
		"System global unit size ranking = <sr>";
	ui = box(text(unitInfo, fontSize(11), left()), fillColor(column_color), left());
	
	//Duplication information
	set[loc] methodLocations = {methodLocation | <methodLocation,_,_,_,_,_> <- flis};
	int numberOfDuplications = getCodeDuplicationInformation(toList(methodLocations));
	real duplicationRate = getDuplicationPercentage(numberOfDuplications, volume);

	str duplInfo = "CODE DUPLICATION" + "\n" +	
		"Number of duplicated lines of code: <numberOfDuplications>" + "\n" +
		"Duplication percentage: <precision(duplicationRate, 3)>" + "\n" +
		"Duplication Rank: <rankDuplication(duplicationRate)>";
	di = box(text(duplInfo, fontSize(11), left()), fillColor(menu_color), left());
	
	leftContent = vcat([tit, makeMenu()], gap(10), shrink(0.95));
	mainContent = vcat([vi, ci, ui, di], gap(3), shrink(0.95));
	show();	
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
	return methodMetrics;}

public int getLinesOfCode(loc methodDefinition) {
	FileLineInformation fli = countLinesOfCodeOfMethod(methodDefinition);
	return fli.linesOfCode;
}

public int getComplexity(loc methodDefinition, str methodName, set[ComplexityInformation] cis) {
	loc PROJECT = |project://Jabberpoint2|;
	M3 model = createM3FromEclipseProject(PROJECT);
	set[loc] projectdecl = {y | <x,y> <- model.declarations, x.scheme=="java+method", x.path == methodDefinition.path};
	if (size(projectdecl) == 0) return -1;	
	set[int] compls = {compl | <decl,name,compl> <- cis, decl.path == getOneFrom(projectdecl).path && name == methodName};
	if (size(compls) == 0) return -1;
	return getOneFrom(compls);
}
