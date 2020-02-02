module Main

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;
import util::Math;

import Complexities;
import Volumes;
import Analytics;
import Duplication;
import Visualization;

public void main() {
	loc PROJECT = |project://Jabberpoint2|;
	println("Building model and calculating analytics... Please be patient.\n");
	
	M3 model = createM3FromEclipseProject(PROJECT); 
	set[FileLineInformation] flis = countLinesOfCodePerMethod(model);
	set[ComplexityInformation] cis = calculateComplexities(PROJECT);
	
	initializeVisualization(model);
//	showClassesInGrid();	
	showBasicClassGraph();
//	showClassDetails(|java+class:///MenuController|);	
	
/*	
	printGeneralInformation(PROJECT);
	printVolumeAnalytics(PROJECT, flis);
	printComplexityInformation(PROJECT, flis, cis);
	printUnitSizeInformation(PROJECT, flis);
	printDuplicationInformation(PROJECT, flis, getTotalVolume(flis));

	printVolumeDetails(flis);
	printComplexityDetails(cis);
*/}

public void	printGeneralInformation(loc project) {
	Resource projectResource = getProject(project);
	set[loc] javafiles = { f | /file(f) <- projectResource, f.extension == "java"};
	
	println();
	println("General Information\n");
	println("***************************************");
	println();	
	println("Projectlocation = <project>"); 
	print("# of java files = ");
	println(size(javafiles));	
}

public void	printVolumeAnalytics(loc project, set[FileLineInformation] flis) {
	int volume = getTotalVolume(flis);
	println();
	println("Evaluating volumes");
	println("***************************************\n");
	//set[FileLineInformation] flis = countLOC(project);
	print("Number of methods = ");
	println(size(flis));
	println("Lines of code of methods excluding blank lines, comments and documentation:");
	println("Total Volume for <project> = <volume>");
	print("Ranking for the total volume of this Java system = ");
	println(rankTotalVolume(volume));
	println();
	int siz = getHighestVolumeFile(flis);
	int nrOfMethods = size(getMethodsWithHighestVolume(flis));
	println("Highest Volume method for <project> = <siz> (<nrOfMethods> method(s))");
	siz = getLowestVolumeFile(flis);
	nrOfMethods = size(getMethodsWithLowestVolume(flis));
	println("Lowest Volume method for <project> = <siz> (<nrOfMethods> method(s))");
	print("Average Volume for <project> = ");
	println(toInt(getAverageVolumeFile(flis)));
	real med = getMedianVolumeFile(flis);
	nrOfMethods = size(getMethodsWithMedianVolume(flis));
	println("Median Volume method for <project> = <med> (<nrOfMethods> method(s))");
}

public void	printComplexityInformation(loc project, set[FileLineInformation] flis, set[ComplexityInformation] cis) {	
	println();
	println("Evaluating complexities");
	println("***************************************\n");

	set[tuple[str,int,int]] locPerRisk = getLinesOfCodePerRisk(cis,flis);
	println("Lines of code per risk (absolute)\n(riskname, number of methods in this risk category, lines of codes in this risk category):\n<locPerRisk>");

	set[tuple[str,int,int,real]] percPerRisk = getPercentageOfLinesOfCodePerRisk(cis,flis);
	println("Lines of code per risk (percentage)\n(riskname, lines of codes in this risk category, the percentage relative to the total Volume):\n<percPerRisk>");

	map[str,real] percPerRiskMap = (risk : perc | <risk,_,_,perc> <- percPerRisk);
	str systemRating = rateSystemComplexity(percPerRiskMap);
	println();
	println("System global complexity ranking = <systemRating>");
}

public void	printUnitSizeInformation(loc project, set[FileLineInformation] flis) {
	println();
	println("Evaluating unit sizes");
	println("***************************************\n");
	
	println("Risks for unit sizes\n(riskname, number of methods, linesOfCode in this category):");
	println(getMethodsPerUnitSizeRank(flis));
	
	println("Risks for unit sizes in percentages\n(riskname, lines of Code in this category, totalVolume, percentage of linesOfCode in this category):");
	percPerRisk = getPercentageOfLinesOfCodePerRisk (flis);
	println(percPerRisk);
	
	percPerRiskMap = (risk : perc | <risk,_,_,perc> <- percPerRisk);
	systemRating = rateSystemUnitsize(percPerRiskMap);
	println();
	println("System global unit size ranking = <systemRating>");
}

public void	printDuplicationInformation(loc project, set[FileLineInformation] flis, int volume) {
	println();
	println("Evaluating duplications");
	println("***************************************\n");
	
	set[loc] methodLocations = {methodLocation | <methodLocation,_,_,_,_,_> <- flis};
	
	int numberOfDuplications = getCodeDuplicationInformation(toList(methodLocations));
	real duplicationRate = getDuplicationPercentage(numberOfDuplications, volume);

	println("Evaluation duplications\n");
	println("Number of duplicated lines of code: <numberOfDuplications>");
	println("Duplication percentage: <precision(duplicationRate, 3)>");
	println("Duplication Rank: <rankDuplication(duplicationRate)>");
}

public void	printVolumeDetails(set[FileLineInformation]flis) {
	println();
	println("Details on Volumes:");
	println("***************************************\n");
	for(fli <- flis) {
		print(toString(fli));
	}
}

public void	printComplexityDetails(set[ComplexityInformation] cis) {
	println();
	println("Details on Complexities:");
	println("***************************************\n");	
	for (ci <- cis) {
		print(toString(ci));
	}
}
