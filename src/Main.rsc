module Main

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

public void main() {
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};
	countLOC();
		
	print("# of java files = ");
	println(javafiles);
}

/* This method counts the lines of code over all the java-files, comments and blank lines excluded.
 * First count all lines
 * secondly count all blank lines
 * thirdly count all comment lines (starting with // or between /* and its counterpart 
 * except if these are surrounded by a pair of quotes)
 */

//TODO to finish end refine
public void countLOC() {
	//first try with one file
//	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};
	loc file = |project://SmallSQL-master/src/main/java/smallsql/database/Distinct2.java|;
	
	//total number of lines
	list[str] lines = readFileLines(file);
	int totalLines= size(lines);
	print("Total #lines in Distinct.java = ");
	println(totalLines);
	
	//number of blank lines	
	list[str] blanklines = [ line | line <- lines, /^\s*$/ := line];
	int nrOfBlankLines= size(blanklines);
	print("Total # of blank lines in Distinct.java = ");
	println(nrOfBlankLines);
	
	//number of commentlines using '//'
	list[str] slashCommentlines = [ line | line <- lines, /^\s*\/{2,}/ := line];
	int nrOfSlashCommentlines= size(slashCommentlines);
	print("Total # of comment lines using // in Distinct2.java = ");
	println(nrOfSlashCommentlines);
	
	//number of commentlines using the slash with star
	str fileString = readFile(file);
	str tempString = fileString;
	int count = 0;

	while (/<firstbegin:.*?(?=\/\*)><begintag:\/\*><firstend:.*>/s := tempString) {
		if ((firstbegin != "") && !(/\n\s*$/ := firstbegin || (/^\s*$/  := firstbegin))) {
			count -= 1;
		}

		bool endtagFound = /<newbegin:><endtag:\*\/><newend:.*>/s := firstend;
		if (/<newbegin:.*?(?=\*\/)><endtag:\*\/><newend:.*>/s := firstend) {
			count += readNrOfLines(newbegin);
			if (!(/^[\s]*\n/ := newend)) {
				count -= 1;
			}
			tempString = newend;		
		} else {
				println("Exception: bad construction");
		}
	}
	int countRest = readNrOfLines(tempString);
	int nrOfStarCommentLines = count;
	print("Total # of comment lines using /* in Distinct2.java = ");
	println(nrOfStarCommentLines);
}

private int readNrOfLines(str text) {
	int count = 0; 
	if (text == "") {
		return 0;
	} else {
		count = 1;
	}
	while (/^<begin:[^\n]*>\n<end:.*>/s := text) {
		count += 1;
		text = begin + end;
	}
	return count;
}
