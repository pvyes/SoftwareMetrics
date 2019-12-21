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
	loc PROJECT = |project://smallsql|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));

	println("***************************************");
	println("Evaluating volumes\n");
	//set[FileLineInformation] flis = countLOC(project);
	set[FileLineInformation] flis = countLinesOfCodePerMethod(PROJECT);
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
	println("***************************************");
	println("Evaluating complexities\n");
	set[ComplexityInformation] cis = calculateComplexities(PROJECT);
	
	println();
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
}