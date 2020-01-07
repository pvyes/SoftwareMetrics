module Duplication

import IO;
import Type;
import Prelude;
import Tuple;

import reader::Reader;

import Common;


public int CODE_BLOCK_SIZE = 6;

alias DuplicationInformaton = tuple[int totalLinesOfCode, int numberOfDuplications];


public DuplicationInformaton getCodeDuplicationInformation(list[loc] methodLocations)
{
	//Create all code clocks
	list[list[str]] codeBlocks = createCodeBlocks(methodLocations);	
	return <(size(codeBlocks) * CODE_BLOCK_SIZE), getDuplications(codeBlocks)>;
}


private int getDuplications(list[list[str]] codeBlocks){

	list[int] duplications = [0];	
	if(size(codeBlocks) == 1)
		return 0;

	pivot = pop(codeBlocks)[0];
	codeBlocksToProcess = pop(codeBlocks)[1];
	duplications += [1 | block <- codeBlocksToProcess, pivot == block ];
	
	return sum(duplications)
			 + getDuplications(codeBlocksToProcess);	
}

private list[list[str]] createCodeBlocks(list[loc] locations){
	
	list[list[str]] codeBlocks = [];
	
	for (location <- locations) {
		
		//remove all type of comments and whitespaces
		str sourceCode = readFile(location);
		list[str] sourceCodeLines = cleanSourceCode(sourceCode);
		
		if (size(sourceCodeLines) < CODE_BLOCK_SIZE) continue;
		
		//create all possible code blocks of 6 lines
		list[str] codeBlock = [];
		int i = 0;
		for (line <- sourceCodeLines) {
			line = trim(line); // remove leading spaces
			
			if( i < CODE_BLOCK_SIZE) {
				codeBlock += line;
				i += 1;
			} else {
				codeBlock = drop(1, codeBlock); //drop first line 
				codeBlock += line; // add new line to keep codeBlcoks at CODE_BLOCK_SIZE				
				codeBlocks += [codeBlock];
			}
		}
	}
	return codeBlocks;
}

private list[str] cleanSourceCode(str sourceCode){
	return removeWhiteSpaces(removeComments(sourceCode));
}

public list[str] removeComments(str sourceCode){
	
	set[str] comments = ({comment |/<comment:\/\*[\S\s]*?\*\/|[ \t\n]*\/\/.*>/ := sourceCode});
	
	str cleanSourceCode = sourceCode;
	for(commentToReplace <- comments){
		cleanSourceCode = replaceAll(sourceCode, commentToReplace, "");
	}
	
	list[str] lines = split("\n", cleanSourceCode);
	
	return lines;
}

public list[str] removeWhiteSpaces(list[str] lines){
	
	list[str] linesWithoutWhiteSpaces = [];	
	for(line <- lines){
		if(!(/^[ \s\r\t\n]*$/ := line)){
			linesWithoutWhiteSpaces += line;
		}
	}
	
	return linesWithoutWhiteSpaces;
}