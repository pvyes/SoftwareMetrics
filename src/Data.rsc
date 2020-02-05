module Data

import util::Math;

alias CCRiskEvaluation = rel[str risk, int min,int max];
alias ComplexityRating = lrel[str risk, int min,int max];
alias MaxRelativeLOC = lrel[str rank, int moderate, int high, int very_high];
alias LinesOfJavaCodeRanking = lrel[str rank, int min, int max];
alias DuplicationRanking = lrel[str rank, int min, int max];

int maxInt = round(exp(ln(2) * 31)) - 1;

/**
 * Returns a relation type CCRiskEvaluation to measure the cyclomatic complexity risk evaluation, containing min complexity, max complexity and risk.
 */
public CCRiskEvaluation getCCRiskEvaluation() {
	return {
		<"low",0,10>,
		<"moderate", 11,20>,
		<"high", 21,50>,
		<"very high",51,maxInt>
	};
}

public ComplexityRating getComplexityRanking() {
return [
		<"low", 0, 10>,
		<"moderate", 11, 20>,
		<"high", 21, 50>,
		<"very high", 51, maxInt>
	];
}

/**
 * Returns a listrelation of type MaxRelativeLoc to measure the percentage of lines of code of a specific cc risk, containing rank, min complexity, max complexity and risk.
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
 * Returns a listrelation of type LinesOfJavaCodeRanking to rank the volume lines of code containing rank, min loc's, max loc's.
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
 * Returns a listrelation of type LinesOfJavaMethodsRanking to rank the volume lines of code per method containing rank, min loc's, max loc's.
 */
public LinesOfJavaCodeRanking getLinesOfJavaCodeMethodsRanking() {
	return [
		<"low", 0, 30>,
		<"moderate", 31, 44>,
		<"high", 45, 74>,
		<"very high", 75, maxInt>
	];
}

/**
 * Returns a listrelation of type DuplicationRanking to rank the duplication containing rank, min duplication percentage, max duplication percentage.
 */
 public DuplicationRanking getDuplicationRanking() {
	return [
		<"++", 0, 2>,
		<"+", 3, 4>,
		<"o", 5, 9>,
		<"-", 10, 19>,
		<"--", 20, 100>
	];
}