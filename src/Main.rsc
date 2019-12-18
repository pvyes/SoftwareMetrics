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

	set[FileLineInformation] flis = countLOC(project);
	println("Lines of code excluding blank lines, comments and documentation;");
	print("Total Volume for <PROJECT> = ");
	println(getTotalVolume(flis));
	print("Highest Volume File for <PROJECT> = ");
	println(getHighestVolumeFile(flis));
	print("Lowest Volume File for <PROJECT> = ");
	println(getLowestVolumeFile(flis));
	print("Average Volume for <PROJECT> = ");
	println(toInt(getAverageVolumeFile(flis)));
	print("Median Volume for <PROJECT> = ");
	println(getMedianVolumeFile(flis));
	
	println("\nDetails on Volumes:");
	for(fli <- flis) {
		print(toString(fli));
	}
	
//	println(calculateComplexities(project));		
}

