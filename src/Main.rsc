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

public void main() {
	loc PROJECT = |project://Jabberpoint|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));
	set[FileLineInformation] flis = countLinesOfCodePerMethod(PROJECT);
/*	set[FileLineInformation] flis = getLinesOfCodePerFile(PROJECT);*/

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