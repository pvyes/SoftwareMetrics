module Main

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;
import util::Math;

import Complexity;
import Volumes;
import Analytics;

public void main() {
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));

	//set[FileLineInformation] flis = countLOC(project);
	set[FileLineInformation] flis = countLinesOfCodePerMethod(PROJECT);
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
	
	println("\nDetails on Volumes:");
	for(fli <- flis) {
		print(toString(fli));
	}
println();
println();
	println(toCSV(flis));
	
//	println(calculateComplexities(project));		
}

