module Analytics

import Prelude;
import analysis::statistics::Descriptive;
import util::Math;
 
import Volume;
import Complexity;

alias CCRiskEvaluation = lrel[int min,int max, str risk];
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
/*Functions calculating the complexity
*/
public int getMaxInt() {
	return roundexp(ln(2) * 31) - 1;
}

public CCRiskEvaluation getCCRiskEvaluation() {
	int maxInt = getMaxInt();
	return [<0,10,"low">,<11,20,"moderate">,<21,50,"high">,<51,maxInt,"very high">];
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

public void rateSystem() {
	map[str,int] percPerRisk = ("low":67,"moderate":20,"high":7,"very high":3);
	MaxRelativeLOC mrl = getMaxRelativeLOC();
	str rating = mrl[4].rank;
	for (int i <- [4..-1]) {
	println(i);
		if (percPerRisk["moderate"] <= mrl[i].moderate && percPerRisk["high"] <= mrl[i].high && percPerRisk["very high"] <= mrl[i].very_high) { 
			rating = mrl[i].rank;
		}
	}
	println(rating);
}