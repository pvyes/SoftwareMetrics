module Volumes

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

alias FileLineInformation = tuple[loc fileLocation, int nrOfLines, int nrOfBlankLines, int nrOfSlashCommentLines, int nrOfStarCommentLines, int linesOfCode];

/* This method counts the lines of code over all the java-files, comments and blank lines excluded.
 * First count all lines
 * secondly count all blank lines
 * thirdly count all comment lines (starting with // or between /* and its counterpart 
 * except if these are surrounded by a pair of quotes)
 */
public set[FileLineInformation] countLinesOfCodePerMethod(loc project) {
	M3 model = createM3FromEclipseProject(project); 
    rel[loc,loc] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+method" || x.scheme=="java+constructor"};                   
	set[FileLineInformation] flis = {countLinesOfCodeOfMethod(l) | <m,l> <- methods};
	return flis;
}

public set[FileLineInformation] countLinesOfCodePerMethod(M3 model) { 
    rel[loc,loc] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+method" || x.scheme=="java+constructor"};                   
	set[FileLineInformation] flis = {countLinesOfCodeOfMethod(l) | <m,l> <- methods};
	return flis;
}

public FileLineInformation countLinesOfCodeOfMethod(loc method) {

	FileLineInformation fileLineInformation = <method, 0, 0, 0, 0, 0>;	
	//total number of lines
	list[str] lines = readFileLines(method);
	int nrOfLines= size(lines);
	fileLineInformation.nrOfLines = nrOfLines;
	
	//number of blank lines	
	list[str] blanklines = [ line | line <- lines, /^\s*$/ := line];
	int nrOfBlankLines= size(blanklines);
	fileLineInformation.nrOfBlankLines = nrOfBlankLines;
	
	//number of commentlines using '//'
	list[str] slashCommentLines = [ line | line <- lines, /^\s*\/{2,}/ := line];
	int nrOfSlashCommentLines= size(slashCommentLines);
	fileLineInformation.nrOfSlashCommentLines = nrOfSlashCommentLines;

	//number of commentlines using the slash with star
	int nrOfStarCommentLines = countNrOfStarCommentLines(method);
	fileLineInformation.nrOfStarCommentLines = nrOfStarCommentLines;
	
	int finalCount = nrOfLines - (nrOfBlankLines + nrOfSlashCommentLines + nrOfStarCommentLines);
	fileLineInformation.linesOfCode = finalCount;

	return fileLineInformation;
}

//returns -1 if a bad construction has been found.
private int countNrOfStarCommentLines(file) {
	str fileString = readFile(file);
	str tempString = fileString;
	int count = 0;

	while (/<firstbegin:.*?(?=\/\*)><begintag:\/\*><firstend:.*>/s := tempString) {		
		str newEnd = betweenParentheses(firstbegin, firstend); //if the begintag is between parentheses, begin gain, starting from the closing parentheses. 
		if (newEnd != "") {
				tempString = newEnd;
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
					println("Exception: bad construction of <file>"); //should not be reached if the program is compiled properly
					return -1;
			}
		}
	}
	return count;
}

private str betweenParentheses(str begintext, str endtext) {
	int nrOfParentheses = countNrOfParentheses(begintext);
	if (!(nrOfParentheses % 2 == 0)) {
		bool parenthesesFound = (/^<begin:.*?(?=["'])>["']<end:.*>/s := endtext);
		return end;
	}
	return "";
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

public str toString(FileLineInformation fli) {
	loc l = fli.fileLocation;
	str s = l.path;
	s += "\t<fli.nrOfLines>";
	s += "\t<fli.nrOfBlankLines>";
	s += "\t<fli.nrOfSlashCommentLines>";
	s += "\t<fli.nrOfStarCommentLines>";
	s += "\t<fli.linesOfCode>";
	s += "\n";
	return s;
}

public str toCSV(set[FileLineInformation] flis) {
	str header = "location,nrOfLines,nrOfBlankLines,nrOfSlashCommentLines,nrOfStarCommentLines,linesOfCode\n";	
	str s = "";
	int i = 1;
	for (fli <- flis) {
		loc l = fli.fileLocation;
		s += l.path;
		s += ",<fli.nrOfLines>";
		s += ",<fli.nrOfBlankLines>";
		s += ",<fli.nrOfSlashCommentLines>";
		s += ",<fli.nrOfStarCommentLines>";
		s += ",<fli.linesOfCode>";
		s += "\n";
	}
	return header + s;
}
