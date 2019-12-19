module Duplication

import IO;
import Type;
import Prelude;
import List;
import reader::Reader;

import Common;

//TODO remove leading spaces
public int getCodeDuplications(list[loc] methodLocations)
{
	list[list[str]] codeBlocks = [];
	int processCodeBlocks = 0;
	
	for (methodLocation <- methodLocations) {

		list[str] lines = countLocPerFile(location);

		if (size(lines) < 6) continue;
		
		//create all possible code blocks of 6 lines
		for (line <- lines) {
			line = trim(line); // remove leading spaces
			
			if( i < 6) {
				codeBlock += line;
				i += 1;
			} else {
				codeBlock = drop(1, codeBlock); //drop first line 
				codeBlock += line; // add new line to keep codeBlcoks of 6 lines
				
				codeBlocks += codeBlock;
				
		}
		
		//Todo
		//Compare half of the block with the other half

}


