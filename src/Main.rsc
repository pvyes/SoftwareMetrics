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

//TODO to finfish end refine
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
	str voorbeeld = "    \n   /*begin:comment1 zjdbckzjbc/* nestedcomment */ djcbqjdbcq \n Tekst * tekst en \n lijntjes * tekst /* zonder lijn \n comentaar \\ comentaar \n end:comment1*/ "
		+ "\n tekst en tekst en \n lijntjes en tekst /*begin:comment2 zonder lijn \n comentaar \\ comentaar \n end:comment2*/ met tekst erachter \n //moet dus niet meegerekend worden.";
		
	str voorbeeld2 = "    \n   /* zjdbckzjbc djcbqjdbcq \n Tekst * tekst en \n lijntjes * tekst /  * zonder lijn \n comentaar \\ comentaar \n *  / "
		+ "\n tekst en tekst en \n lijntjes en tekst /  * zonder lijn \n comentaar \\ comentaar \n *  / met tekst erachter \n //moet dus niet meegerekend worden.";
		
	str voorbeeld3  = " g//ewone *tekst";
	println();
	println(voorbeeld);
	
	list[str] comments = [];
	while (/<begin:.*><comment:\/\*.*?\*\/><end:.*>/s := voorbeeld) {
		println();
		println("begin = "  +begin);
		println("comment = " + comment);
		println("end = " + end);
		println();
		voorbeeld = begin + end;
		println(voorbeeld);
	}	
	
	bool gevonden1 = (/<comment:\/\*.*?\*\/>/ := voorbeeld);
	bool gevonden2 = (/\/\*.*\*\// := voorbeeld2);
	bool gevonden3 = (/\/\*.*\*\// := voorbeeld3);
	
/*	print("Total # of comment lines using /* in Distinct2.java = ");
	println();
	println(voorbeeld);
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
