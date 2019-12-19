module Common

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;


private int countLocPerFile(loc file) {
	//total number of lines
	list[str] lines = readFileLines(file);
	int nrOfLines= size(lines);
	
	//number of blank lines	
	list[str] blanklines = [ line | line <- lines, /^\s*$/ := line];
	int nrOfBlankLines= size(blanklines);
	
	//number of commentlines using '//'
	list[str] slashCommentlines = [ line | line <- lines, /^\s*\/{2,}/ := line];
	int nrOfSlashCommentlines= size(slashCommentlines);
	
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
	
	int linesOfCode = nrOfLines - (nrOfBlankLines + nrOfSlashCommentlines + nrOfStarCommentLines);
	
	return linesOfCode;
}	
