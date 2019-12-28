module Analytics

import Prelude;
import analysis::statistics::Descriptive;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Math;
 
import Volumes;
import Complexities;

alias CCRiskEvaluation = rel[int min,int max, str risk];
alias MaxRelativeLOC = lrel[str rank, int moderate, int high, int very_high];

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


/*
Functions calculating the complexity
*/

public int getMaxInt() {
	return round(exp(ln(2) * 31)) - 1;
}

public CCRiskEvaluation getCCRiskEvaluation() {
	int maxInt = getMaxInt();
//	return [<0,10,"low">,<11,20,"moderate">,<21,50,"high">,<51,maxInt,"very high">];
	//for testing with Jabberpoint
	return {<0,1,"low">,<2,3,"moderate">,<4,4,"high">,<5,maxInt,"very high">};
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

/**
 * Returns a set of tuples with the risk-name, the numberOfMethods and the linesOfCode in this risk category. 
 */
public set[tuple[str,int,int]] getLinesOfCodePerRisk (set[ComplexityInformation] cis, set[FileLineInformation] flis) {
	set[tuple[str,int,int]] ratings = {};
	tuple[str rank, int numberOfMethods, int linesOfCode] rating = <"",0,0>;
	CCRiskEvaluation ccre = getCCRiskEvaluation();
	for (re <- ccre) {
		set[ComplexityInformation] cisPerRisk = gatherComplexitiesByRisk(cis, re.risk);
		int numberOfMethods = size(cisPerRisk);
		int linesOfCode = countLinesOfCis(cisPerRisk, flis);
		rating = <re.risk, numberOfMethods, linesOfCode>;
		ratings += rating;
	}
	return ratings;	
}

/**
 * Returns a set of tuples with the risk-name, the linesOfCode in this risk category, the total volume (LOC) and the percentage relative to the total Volume. 
 */
public set[tuple[str,int,int,real]] getPercentageOfLinesOfCodePerRisk (set[ComplexityInformation] cis, set[FileLineInformation] flis) {
	set[tuple[str,int,int]] ratings = getLinesOfCodePerRisk(cis, flis);
	set[tuple[str,int,int,real]] percentages = {}; 
	int totalVolume = getTotalVolume(flis);
	CCRiskEvaluation ccre = getCCRiskEvaluation();
	for (<risk,_,linesOfCode> <- ratings) {
		real percentage = toReal(linesOfCode) / toReal(totalVolume) * 100.;
		rating = <risk, linesOfCode, totalVolume, percentage>;
		percentages += rating;
	}
	return percentages;	
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
	set[FileLineInformation] tempFlis = flis;
//	println("\n/*****countLinesOfCis (per risk) *******/");
	for(<_,_,_,locInfo> <- cisPerRisk) {
		int i = 0;
		for (fli <- tempFlis) {
			if (findLocInfoInVolumeInfo(fli.fileLocation, locInfo)) {
//				println("location = <locInfo>; linesOfCode = <fli.linesOfCode>");
				count += fli.linesOfCode;
				tempFlis -= fli;
			}
		}
//		println("Total for this <locInfo> = <count>"); 
	}
//	println("Total for this risk = <count>"); 
	return count;	
}

public str rateSystem(map[str, real] percPerRisk) {
	MaxRelativeLOC mrl = getMaxRelativeLOC();
	str rating = mrl[4].rank;
	for (int i <- [4..-1]) {
		if (percPerRisk["moderate"] <= mrl[i].moderate && percPerRisk["high"] <= mrl[i].high && percPerRisk["very high"] <= mrl[i].very_high) { 
			rating = mrl[i].rank;
		}
	}
	return rating;
}

public bool findLocInfoInVolumeInfo(loc fileLocation, LocInfo locInfo) {
	//print("method: <fileLocation.uri> CONTAINS? complexity: <locInfo.locationUri> IS ");
	if (fileLocation.uri == locInfo.locationUri && fileLocation.offset <= locInfo.offset && fileLocation.length + fileLocation.offset >= locInfo.length + locInfo.offset) {
	//	println("true");
		return true;
	}
	return false;
}