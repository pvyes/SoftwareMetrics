module Main

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import Complexity;

public void main() {
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};

	print("# of java files = ");
	println(size(javafiles));

	print("Lines of code excluding blank lines, comments and documentation = ");
//	println(countLOC(javafiles));
	
	println(calculateComplexities(project));
		
}

/* This method counts the lines of code over all the java-files, comments and blank lines excluded.
 * First count all lines
 * secondly count all blank lines
 * thirdly count all comment lines (starting with // or between /* and its counterpart 
 * except if these are surrounded by a pair of quotes)
 */

private int countLOC(set[loc] files) {
	int linesOfCode = sum([countLocPerFile(f) | f <- files]);
	return linesOfCode;
}

private int countLocPerFile(loc file) {
	//total number of lines
	list[str] lines = readFileLines(file);
	int nrOfLines= size(lines);
//	print("Total #lines in Distinct.java = ");
//	println(nrOfLines);
	
	//number of blank lines	
	list[str] blanklines = [ line | line <- lines, /^\s*$/ := line];
	int nrOfBlankLines= size(blanklines);
//	println("Total # of blank lines in <file> = <nrOfBlankLines>");
	
	//number of commentlines using '//'
	list[str] slashCommentlines = [ line | line <- lines, /^\s*\/{2,}/ := line];
	int nrOfSlashCommentlines= size(slashCommentlines);
//	print("Total # of comment lines using // in <file> = ");
//	println(nrOfSlashCommentlines);
	
	//number of commentlines using the slash with star
	str fileString = readFile(file);
	str tempString = fileString;
	int count = 0;

	while (/<firstbegin:.*?(?=\/\*)><begintag:\/\*><firstend:.*>/s := tempString) {
		
		int nrOfParentheses = countNrOfParentheses(firstbegin);
		if (nrOfParentheses % 2 != 0) {
				bool parenthesesFound = (/^<begin:.*?(?=["'])>["']<end:.*>/s := firstend);
				tempString = end;
				firstbegin = "";
				firstend = "";
		} else {

			if ((firstbegin != "") && !(/\n\s*$/ := firstbegin || (/^\s*$/  := firstbegin))) {
				count -= 1;
			}
	
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
	}
	int countRest = readNrOfLines(tempString);
	int nrOfStarCommentLines = count;
//	print("Total # of comment lines using /* in <file> = ");
//	println(nrOfStarCommentLines);
	
	int linesOfCode = nrOfLines - (nrOfBlankLines + nrOfSlashCommentlines + nrOfStarCommentLines);
	
	return linesOfCode ;
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

private int countNrOfParentheses(str text) {
	int count = 0; 
	if (text == "") {
		return 0;
	}
	while (/^<begin:.*>["']<end:.*>/s := text) {
		count += 1;
		text = begin + end;
	}
	return count;
}
