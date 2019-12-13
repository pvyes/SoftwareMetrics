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
	str voorbeeld = "  eerst wat tekst  \n   /*begin:comment1 zjdbckzjbc/* nestedcomment */ djcbqjdbcq \n Tekst * tekst en \n lijntjes * tekst /* zonder lijn \n comentaar \\ comentaar \n end:comment1*/ "
		+ "\n tekst en tekst en \n lijntjes en tekst /*begin:comment2 zonder lijn \n comentaar \\ comentaar \n end:comment2*/ met tekst erachter \n //moet dus niet meegerekend worden.";
		
	str voorbeeld2 = "    \n   /* zjdbckzjbc djcbqjdbcq \n Tekst * tekst en \n lijntjes * / tekst /* zonder lijn \n comentaar \\ comentaar \n * / "
		+ "\n tekst en tekst en \n lijntjes en tekst /* zonder lijn \n comentaar \\ comentaar \n */ met tekst erachter \n //moet dus niet meegerekend worden.";
		
	str voorbeeld3  = " g//ewone *tekst";
	int total = readNrOfLines(voorbeeld2);
//	str tempString = fileString;
//	str tempString = voorbeeld;
//	str tempString = voorbeeld2;
	str tempString = voorbeeld3;
	
	println();
	println(tempString);
	print("#lines = ");
	println(total);
	println();
	//list[str] comments = [];
/*	while (/<begin:><comment:\/\*.*?\*\/><end:.*>/s := tempString) {
		println();
		println("begin = "  +begin);
		println("comment = " + comment);
		println("end = " + end);
		println();
		tempString = begin + end;
		println(voorbeeld);
	}
*/	int count = 0;
//	while (/<firstbegin:[^(\/\*)]*><begintag:\/\*><firstend:.*>/s := tempString) {
	while (/<firstbegin:.*?(?=\/\*)><begintag:\/\*><firstend:.*>/s := tempString) {
		print("firstbegin = \n\t"  + firstbegin + "\n");
		print("commenttag = \n\t" + begintag + "\n");
		print("firstend = \n\t" + firstend);
		println();
		
		if ((firstbegin != "") && !(/\n\s*$/ := firstbegin || (/^\s*$/  := firstbegin))) {
			count -= 1;
			println("count -= 1");
		}
		println("count = <count>");
		bool endtagFound = /<newbegin:><endtag:\*\/><newend:.*>/s := firstend;
//		if (/<newbegin:.*[^(\*\/)]><endtag:\*\/><newend:.*>/s := firstend) {
		if (/<newbegin:.*?(?=\*\/)><endtag:\*\/><newend:.*>/s := firstend) {
			print("newbegin = \n\t"  + newbegin + "\n");
			print("commenttag = \n\t" + endtag + "\n");
			print("newend = \n\t" + newend);
			println();
			count += readNrOfLines(newbegin);
			if (!(/^[\s]*\n/ := newend)) {
				count -= 1;
				println("count -= 1");
			}
			tempString = newend;		
		} else {
				println("Exception: bad construction");
		}
		println("count = <count>");
	}
	int countRest = readNrOfLines(tempString);
	println("tempString na regex");
	println(tempString);
	print("#lines = ");
	println(countRest);
	println();
	int nrOfStarCommentLines = count;
	print("Total # of comment lines using /* in Distinct2.java = ");
	println(nrOfStarCommentLines);
/*	println(voorbeeld);
	println();
	print("Voorbeeld = ");
	println(gevonden1);	
	print("Voorbeeld2 = ");
	println(gevonden2);
	print("Voorbeeld3 = ");
	println(gevonden3);
*/	
	//number of documentationlines using /**
	
		
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
