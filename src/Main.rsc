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
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));
	
	// Unit Size
	set[Declaration] declarations = createAstsFromEclipseProject(project, true);
	rel[loc, Statement] methods = getMethodsAST(declarations);
	list[int] unitSizesPerMethod = getLinesOfCodePerMethod(methods);
	map[str, int] unitSizeRates =	getUnitSizeRates(unitSizesPerMethod);

	println("***************************************");
    println("Evaluating Unit size metric");
    println("Unit Size risk rates is <unitSizeRates>");

	//Duplication
	map[str, int] duplicationMetrics = getCodeDuplicationMetric(toList(domain(methods)));
	
	println("***************************************");
    println("Evaluating the Duplication metric: ");
    println("Number of duplications: " + duplicationMetrics["duplications"]);
    println("Duplication rate: " + getDuplicationRate(duplicationMetrics["duplications"], duplicationMetrics["total"]));

	println("***************************************");
	println("Evaluating volumes\n");
	//set[FileLineInformation] flis = countLOC(project);
	print("Size of methods = ");
	println(size(flis));
	println("\nLines of code of methods excluding blank lines, comments and documentation:");
	print("Total Volume for <PROJECT> = ");
	println(getTotalVolume(flis));
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
	
	
	println("***************************************");
	println("\nDetails on Volumes:");
	for(fli <- flis) {
		print(toString(fli));
	}

	println();
	println("***************************************");	
	println("\nDetails on Complexities:");
	for (ci <- cis) {
		print(toString(ci));
	}
	
	println(toCSV(flis));
	println();
	println(toCSV(cis));		
}


public map[str, int] getRiskMetrics(list[int] unitSizesPerMethod) {
	
	map[str, int] categories = ();
	categories["simple"] = 0;
	categories["moderate"] = 0;
	categories["complex"] = 0;
	categories["untestable"] = 0;
   	categories["total"] = 0;
	
	for (unitSize <- unitSizesPerMethod) {
	
		//CC Risk evaluation table from paper "A Pratical Model for Measuring Maintanability"
		if (unitSize in [1..11]) {
			categories["low"] += unitSize;
		} else if (unitSize in [11..21]) {
			categories["moderate"] += unitSize;
		} else if (unitSize in [21..51]) {
			categories["complex"] += unitSize;
		} else if (unitSize > 50) {
			categories["untestable"] += unitSize;
		}
		
		categories["total"] += unitSize;
	}
	
	return categories;
}