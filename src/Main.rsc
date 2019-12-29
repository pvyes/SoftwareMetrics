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
import UnitSize;
import Duplication;

public void main() {
	loc PROJECT = |project://Jabberpoint|;
	Resource project = getProject(PROJECT);
	M3 model = createM3FromEclipseProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));
	set[FileLineInformation] flis = countLinesOfCodePerProject(model);
	int volume = getTotalVolume(flis);
	
/*	set[FileLineInformation] flis = getLinesOfCodePerFile(PROJECT);*/

// Unit Size

/*    M3 model = createM3FromEclipseProject(PROJECT);
	set[Declaration] declarations = model.declarations;
	rel[loc, Statement] methods = getMethodsAST(declarations);
	list[int] unitSizesPerMethod = getLinesOfCodePerMethod(methods);
	map[str, int] unitSizeRates =	getUnitSizeRates(unitSizesPerMethod);
	println("***************************************");
    println("Evaluating Unit size metric");
    println("Unit Size risk rates is <unitSizeRates>");
*/

	//Duplication
/*	map[str, int] duplicationMetrics = getCodeDuplicationMetric(toList(domain(methods)));
	
	println("***************************************");
    println("Evaluating the Duplication metric: ");
    println("Number of duplications: " + duplicationMetrics["duplications"]);
    println("Duplication rate: " + getDuplicationRate(duplicationMetrics["duplications"], duplicationMetrics["total"]));

*/

	println("***************************************");
	println("Evaluating volumes\n");
	//set[FileLineInformation] flis = countLOC(project);
	print("Size of methods = ");
	println(size(flis));
	println("\nLines of code of methods excluding blank lines, comments and documentation:");
	println("Total Volume for <PROJECT> = <volume>");
	print("Ranking for the total volume of this Java system = ");
	println(rankTotalVolume(volume));
	int siz = getHighestVolumeFile(flis);
	int nrOfMethods = size(getMethodsWithHighestVolume(flis));
	println("Highest Volume method for <PROJECT> = <siz> (<nrOfMethods> methods(s))");
	siz = getLowestVolumeFile(flis);
	nrOfMethods = size(getMethodsWithLowestVolume(flis));
	println("Lowest Volume method for <PROJECT> = <siz> (<nrOfMethods> methods(s))");
	print("Average Volume for <PROJECT> = ");
	println(toInt(getAverageVolumeFile(flis)));
	real med = getMedianVolumeFile(flis);
	nrOfMethods = size(getMethodsWithMedianVolume(flis));
	println("Median Volume method for <PROJECT> = <med> (<nrOfMethods> methods(s))");
	
	println();
	set[ComplexityInformation] cis = calculateComplexities(PROJECT);
	println("***************************************");
	println("Evaluating complexities\n");
	set[tuple[str,int,int]] locPerRisk = getLinesOfCodePerRisk(cis,flis);
	println("Lines of code per risk\nriskname, number of methods in this risk category, lines of codes in this risk category):\n<locPerRisk>");
	set[tuple[str,int,int,real]] percPerRisk = getPercentageOfLinesOfCodePerRisk(cis,flis);
	println("Lines of code per risk\nriskname, lines of codes in this risk category, the percentage relative to the total Volume):\n<percPerRisk>");
	map[str,real] percPerRiskMap = (risk : perc | <risk,_,_,perc> <- percPerRisk);
	str systemRating = rateSystemComplexity(percPerRiskMap);
	println("System global complexity ranking = <systemRating>");

	println();
	println("***************************************");
	println("Evaluating unit sizes\n");
	println("Risks for unit sizes\n(riskname, number of methods, linesOfCodein this category):");
	println(getMethodsPerUnitSizeRank(flis));
	println("Risks for unit sizes in percentages\n(riskname, lines of Code in this category, totalVolume, percentage of linesOfCodein this category):");
	println(getPercentageOfLinesOfCodePerRisk (flis));
	percPerRiskMap = (risk : perc | <risk,_,_,perc> <- percPerRisk);
	systemRating = rateSystemUnitsize(percPerRiskMap);
	println("System global unit size ranking = <systemRating>");
	println();
	println("***************************************");
	
	//Duplication
	
	M3 model = createM3FromEclipseProject(PROJECT);
	set[Declaration] declarations = model.declarations;
	rel[loc, Statement] methods = getMethodsAST(declarations);
	
	map[str, int] metrics = getCodeDuplicationMetric(toList(domain(methods)));
	println();
	println("***************************************");
	println("Evaluation duplications\n");
	println("Rank for duplications in percentages:");
	
	println(getPrecentageOfDuplcations(flis));
	println("Risks for unit sizes in percentages\n(riskname, lines of Code in this category, totalVolume, percentage of linesOfCodein this category):");
	println(getPercentageOfLinesOfCodePerRisk (flis));
	percPerRiskMap = (risk : perc | <risk,_,_,perc> <- percPerRisk);
	systemRating = rateSystemUnitsize(percPerRiskMap);
	println("System global unit size ranking = <systemRating>");
	println();
	println("***************************************");

/*	println("\nDetails on Volumes:");
	for(fli <- flis) {
		print(toString(fli));
	}
*/
	println();
	println("***************************************");	
/*	println("\nDetails on Complexities:");
	for (ci <- cis) {
		print(toString(ci));
	}
*/	
/*	println(toCSV(flis));
	println();
	println(toCSV(cis));
*/}