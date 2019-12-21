module Analytics

import Prelude;
import analysis::statistics::Descriptive;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Math;
 
import Volumes;
import Complexities;

alias CCRiskEvaluation = rel[int min,int max, str risk];
alias MaxRelativeLOC = rel[str rank, int moderate, int high, int very_high];

// Methods analyzing the volume (on set[fileLineInformation])
//	All calculatings are made using the lines of codes

public int getTotalVolume(set[FileLineInformation] flis) {
	return sum([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);
}

public int getHighestVolumeFile(set[FileLineInformation] flis) {
	return max([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);
}

public set[loc] getMethodsWithHighestVolume(set[FileLineInformation] flis) {
	int maximum = max([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);	
	return {location | <location,_,_,_,_,linesOfCode> <- flis, linesOfCode == maximum};
}

public int getLowestVolumeFile(set[FileLineInformation] flis) {
	return min([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);
}

public set[loc] getMethodsWithLowestVolume(set[FileLineInformation] flis) {
	int minimum = min([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);	
	return {location | <location,_,_,_,_,linesOfCode> <- flis, linesOfCode == minimum};
}

public real getAverageVolumeFile(set[FileLineInformation] flis) {	
	return mean([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);	
}

public real getMedianVolumeFile(set[FileLineInformation] flis) {	
	return median([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);
}

public set[loc] getMethodsWithMedianVolume(set[FileLineInformation] flis) {	
	real median = median([linesOfCode | <_,_,_,_,_,linesOfCode> <- flis]);	
	return {location | <location,_,_,_,_,linesOfCode> <- flis, linesOfCode == ceil(median) || linesOfCode == floor(median)};
}
/*Functions calculating the complexity
*/
public int getMaxInt() {
	return round(exp(ln(2) * 31)) - 1;
}

public CCRiskEvaluation getCCRiskEvaluation() {
	int maxInt = getMaxInt();
//	return [<0,10,"low">,<11,20,"moderate">,<21,50,"high">,<51,maxInt,"very high">];
	return {<0,1,"low">,<2,2,"moderate">,<3,4,"high">,<5,maxInt,"very high">};
}

public MaxRelativeLOC getMaxRelativeLOC() {
	return [
		<"++", 25, 0, 0>,
		<"+", 30, 5, 0>,
		<"0", 40, 10, 0>,
		<"-", 50, 15, 5>,
		<"--", 100, 100, 100>
	];
}

public tuple[str, int, int, int] rateSystemComplexity(set[ComplexityInformation] cis, set[FileLineInformation] flis) {
	tuple[str rank, int percModerate, int percHigh, int percVeryHigh] rating = <"",0,0,0>;
	CCRiskEvaluation ccre = getCCRiskEvaluation();
	for (re <- ccre) {
		set[ComplexityInformation] cisPerRisk = gatherComplexitiesByRisk(cis, re.risk);
		tuple[str risk, int nrOfLines] linesOfCis = <re.risk,countLinesOfCis(cisPerRisk, flis)>;
		println(linesOfCis);
	}
	
	return rating;
}

/**
 * gather the complexityInformation per risk.
 * return:  a set of ComplexityInformations belonging to a same risk level as defined in CCRiskInformation. 
 */
public set[ComplexityInformation] gatherComplexitiesByRisk(set[ComplexityInformation] cis, str risk) {
	CCRiskEvaluation ccre = getCCRiskEvaluation();
	set[ComplexityInformation] cisPerRisk = {};
	for (re <- ccre, re.risk == risk) {
		cisPerRisk = {ci | ci <- cis, ci.complexity <= re.max && ci.complexity >= re.min};
	}
	return cisPerRisk;
}

public int countLinesOfCis(set[ComplexityInformation] cisPerRisk, set[FileLineInformation] flis) {
	int count = 0;
	println("cisPerRisk = <size(cisPerRisk)>; flis = <size(flis)>");
	list[ComplexityInformation] l = [top(toList(cisPerRisk))];

	for(<_,_,_,impl> <- l) {	
//	for(<_,_,_,impl> <- cisPerRisk) {
		int i = 0;
		for (fli <- flis) {
			if (findVolumeLocInStatement(fli.fileLocation, impl)) {
				println("inside if <i>.");
				i += 1;
				count += fli.linesOfCode;
			}
		}
	}	
	return count;	
}

public void rateSystem() {
	map[str,int] percPerRisk = ("low":67,"moderate":20,"high":7,"very high":3);
	MaxRelativeLOC mrl = getMaxRelativeLOC();
	str rating = mrl[4].rank;
	for (int i <- [4..-1]) {
		if (percPerRisk["moderate"] <= mrl[i].moderate && percPerRisk["high"] <= mrl[i].high && percPerRisk["very high"] <= mrl[i].very_high) { 
			rating = mrl[i].rank;
		}
	}
	println(rating);
}

public bool findVolumeLocInStatement(loc l, Statement s) {
l = |project://Jabberpoint/src/MenuController.java|(2500,107,<70,3>,<73,4>);
	bool found = false;
	visit(s) {
		case \declarationStatement(stmt): {
			println("<stmt.src>");
			found = stmt.src == l;
			println("<stmt.src>");
			if (found) return found;
   		}
    }
	return found;
}

public bool findVolumeLocInStatement2(loc l, Statement s) {
l = |project://Jabberpoint/src/MenuController.java|(2500,107,<70,3>,<73,4>);
	bool found = false;
	visit(s) {
		case \declarationStatement(stmt): {
			methodOffset = l.offset;
			methodLength = l.length;
			srcOffset = stmt.src.offset;
			srcLength = stmt.src.length;
			printl("methodOffset = <l.offset>; methodLength = <l.length>; srcOffset = <stmt.src.offset>; srcLength = <stmt.src.length>");
			found = (srcOffset >= methodOffset && srcOffset + srcLength <= methodOffset + methodLength);
			println("<found>");
			if (found) return found;
   		}
    }
	return found;
}