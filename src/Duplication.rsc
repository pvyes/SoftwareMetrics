module Duplication

import IO;
import Type;
import Prelude;
import List;
import Tuple;

import reader::Reader;

import Common;

public int CODE_BLOCK_SIZE = 6;

public map[str, int] getCodeDuplicationMetric(list[loc] methodLocations)
{
	map[str, int] metrics = ();
	metrics["duplications"] = 0;
	metrics["totalLines"] = 0;
	
	//Create all code clocks
	list[list[str]] codeBlocks = createCodeBlocks(methodLocations);	
	
	metrics["totalLines"] = size(codeBlocks) * CODE_BLOCK_SIZE;
	
	metrics["duplications"] = getDuplications(codeBlocks);
	
	return metrics;
}


private int getDuplications(list[list[str]] codeBlocks){
	
	if(size(codeBlocks) == 1)
		return 0;
		
	pivot = pop(codeBlocks)[0];
	codeBlocksToProcess = pop(codeBlocks)[1];
	
	int duplications = sum([1 | block <- codeBlocks, pivot == block ]);;
	
	return duplications + getDuplications(codeBlocksToProcess);	
}

private list[list[str]] createCodeBlocks(list[loc] locations){
	
	list[list[str]] codeBlocks = [];
	
	for (location <- locations) {
		
		//remove all tpye of comments and whitespaces
		str sourceCode = readFile(location);
		List[str] sourceCodeLines = cleanSourceCode(sourceCode);
		
		if (size(sourceCodeLines) < CODE_BLOCK_SIZE) continue;
		
		//create all possible code blocks of 6 lines
		for (line <- sourceCodeLines) {
			line = trim(line); // remove leading spaces
			
			if( i < 6) {
				codeBlock += line;
				i += 1;
			} else {
				codeBlock = drop(1, codeBlock); //drop first line 
				codeBlock += line; // add new line to keep codeBlcoks of 6 lines
				
				codeBlocks += codeBlock;
			}
		}
	}
	
	return codeBlocks;
}

private List[str] cleanSourceCode(str sourceCode){
	return removeWhiteSpaces(removeComments(sourceCode));
}

public list[str] removeComments(str sourceCode){
	
	Set[str] comments = ({comment |/<comment:\/\*[\S\s]*?\*\/|[ \t\n]*\/\/.*>/ :=sourceCode});
	
	str cleanSourceCode = sourceCode;
	for(commentToReplace <- comments){
		cleanSourceCode = replaceAll(sourceCode, commentToReplace, "");
	}
	
	List[str] lines = split("\n", cleanSourceCode);
	
	return lines;
}

public list[str] removeWhiteSpaces(List[str] lines){
	
	List[str] linesWithoutWhiteSpaces = [];	

	for(line <- lines){
		if(!(/^[ \s\r\t\n]*$/ := line)){
			linesWithoutWhiteSpaces += line;
		}
	}
	
	return linesWithoutWhiteSpaces;
}
