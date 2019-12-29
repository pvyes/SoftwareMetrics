module Data

import util::Math;

alias CCRiskEvaluation = rel[str risk, int min,int max];
alias MaxRelativeLOC = lrel[str rank, int moderate, int high, int very_high];
alias LinesOfJavaCodeRanking = lrel[str rank, int min, int max];

int maxInt = round(exp(ln(2) * 31)) - 1;

/**
 * Returns a tuple of type CCRiskEvaluation to measure the cyclomatic complexity risk evaluation, containing min complexity, max complexity and risk.
 */
public CCRiskEvaluation getCCRiskEvaluation() {
	/*	return [
		<"low",0,10>,
		<"moderate", 11,20>,
		<"high", 21,50>,
		<"very high",51,maxInt>
	];
*/
	//for testing with Jabberpoint use below:
	return {
		<"low",0,1>,
		<"moderate",2,3>,
		<"high",4,4>,
		<"very high",5,maxInt>
	};
}

/**
 * Returns a tuple of type MaxRelativeLoc to measure the percentage of lines of code of a specific cc risk, containing rank, min complexity, max complexity and risk.
 */
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
 * Returns a tuple of type LinesOfJavaCodeRanking to rank the volume lines of code containing rank, min loc's, max loc's.
 */
public LinesOfJavaCodeRanking getLinesOfJavaCodeTotalVolumeRanking() {
	return [
		<"++", 0, 6600>,
		<"+", 6601, 24600>,
		<"0", 24601, 66500>,
		<"-", 66501, 131000>,
		<"--", 131001, maxInt>
	];
}

/**
 * Returns a tuple of type LinesOfJavaMethodsRanking to rank the volume lines of code per method containing rank, min loc's, max loc's.
 */
public LinesOfJavaCodeRanking getLinesOfJavaCodeMethodsRanking() {
	return [
		<"low", 0, 6>,
		<"moderate", 7, 8>,
		<"high", 9, 14>,
		<"very high", 15, maxInt>
	];
}