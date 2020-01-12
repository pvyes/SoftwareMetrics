module Analytics

import Prelude;
import analysis::statistics::Descriptive;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Math;
 
import Volumes;
import Complexities;
import Data;
import Duplication;

alias UnitSizeEvaluation = rel[str rank, int size];
alias DuplicationEvaluation = rel[str rank, real rate];

public real REAL_PRECISION = 0.01;

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

public str rankTotalVolume(int volume) {
	LinesOfJavaCodeRanking locrs = getLinesOfJavaCodeTotalVolumeRanking();
	str rating = locrs[4].rank;
	for (int i <- [4..-1]) {
		if (volume <= locrs[i].max) { 
			rating = locrs[i].rank;
		}
	}
	return rating;
}

/*
Functions calculating the complexity
*/


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
		percentage = round(percentage, REAL_PRECISION);
		rating = <risk, linesOfCode, totalVolume, percentage>;
		percentages += rating;
	}
	return percentages;	
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
	for(<location,_,_> <- cisPerRisk) {
		count += countLinesOfCodeOfMethod(location).linesOfCode;
	}
	return count;	
}

public str rateSystemComplexity(map[str, real] percPerRisk) {
	MaxRelativeLOC mrl = getMaxRelativeLOC();
	str rating = mrl[4].rank;
	for (int i <- [4..-1]) {
		if (percPerRisk["moderate"] <= mrl[i].moderate && percPerRisk["high"] <= mrl[i].high && percPerRisk["very high"] <= mrl[i].very_high) { 
			rating = mrl[i].rank;
		}
	}
	return rating;
}

//Rating unitsizes

/**
 * Returns a set of tuples with the rank, the numberOfMethods and the linesOfCode in this rank category. 
 */
public set[tuple[str,int,int]] getMethodsPerUnitSizeRank (set[FileLineInformation] flis) {
	set[tuple[str,int,int]] ratings = {};
	tuple[str rank, int numberOfMethods, int linesOfCode] rating = <"",0,0>;

	LinesOfJavaCodeRanking locrs = getLinesOfJavaCodeMethodsRanking();
	for (locr <- locrs) {
		set[FileLineInformation] flisPerRisk = gatherMethodsByRisk(flis, locr.rank);
		int numberOfMethods = size(flisPerRisk);
		int linesOfCode = sum([count | <_,_,_,_,_,count> <- flisPerRisk]);
		rating = <locr.rank, numberOfMethods, linesOfCode>;
		ratings += rating;
	}
	return ratings;	
}

/**
 * gather the FileLineInformation per risk.
 * return:  a set of FileLineInformations belonging to a same risk level as defined in LinesOfJavaCodeMethodsRanking. 
 */
public set[FileLineInformation] gatherMethodsByRisk(set[FileLineInformation] flis, str rank) {
	LinesOfJavaCodeRanking locrs = getLinesOfJavaCodeMethodsRanking();
	set[FileLineInformation] flisPerRank = {};
	for (locr <- locrs, locr.rank == rank) {
		flisPerRank = {fli | fli <- flis, fli.linesOfCode <= locr.max && fli.linesOfCode >= locr.min};
	}
	return flisPerRank;
}

/**
 * Returns a set of tuples with the risk-name, the linesOfCode in this risk category, the total volume (LOC) and the percentage relative to the total Volume. 
 */
public set[tuple[str,int,int,real]] getPercentageOfLinesOfCodePerRisk (set[FileLineInformation] flis) {
	set[tuple[str,int,int]] ratings = getMethodsPerUnitSizeRank(flis);
	set[tuple[str,int,int,real]] percentages = {}; 
	int totalVolume = getTotalVolume(flis);;
	for (<risk,_,linesOfCode> <- ratings) {
		real percentage = toReal(linesOfCode) / toReal(totalVolume) * 100.;
		percentage = round(percentage, REAL_PRECISION);
		rating = <risk, linesOfCode, totalVolume, percentage>;
		percentages += rating;
	}
	return percentages;	
}

public str rateSystemUnitsize(map[str, real] percPerRisk) {
	MaxRelativeLOC mrl = getMaxRelativeLOC();
	str rating = mrl[4].rank;
	for (int i <- [4..-1]) {
		if (percPerRisk["moderate"] <= mrl[i].moderate && percPerRisk["high"] <= mrl[i].high && percPerRisk["very high"] <= mrl[i].very_high) { 
			rating = mrl[i].rank;
		}
	}
	return rating;
}

//Metrics of duplication

public real getDuplicationPercentage(int numberOfDuplications, int totalLinesOfCode) {
	
	return duplicationPercentage= toReal(numberOfDuplications)*100/toReal(totalLinesOfCode);
}
public str rankDuplication(real duplicationRate) {
	DuplicationRanking rankings = getDuplicationRanking();
	str rank = rankings[4].rank;
	for (int i <- [4..-1]) {
		if (duplicationRate < rankings[i].max) { 
			rank = rankings[i].rank;
		}
	}
	return rank;
}