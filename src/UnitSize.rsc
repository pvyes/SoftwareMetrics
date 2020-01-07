module UnitSize

import IO;
import lang::java::jdt::m3::AST;
import List;

public rel[loc, Statement] getMethodsAST(set[Declaration] decls) {
   //set[Declaration] decls = createAstsFromFiles(bestanden, false);
   rel[loc, Statement] result = [];
   visit (decls) {
      case \method(_, _, _, _, impl): result += <m@src, impl>;
      case \constructor(_, _, _, impl): result += <c@src, impl>;
   }
   return(result);
}

public rel[loc, int] getLinesOfCodePerMethod(rel[loc, Statement] methods){
	list[int] result = [];
	for (method <- methods) {
		int locOfMethod = countLocPerFile(method[0]);
		result+=locOfMethod; 
	}
	return result; 
}
/*
public map[str, int] getRiskMetrics(list[int] unitSizesPerMethod) {
	
	map[str, int] categories = ();
	categories["simple"] = 0;
	categories["moderate"] = 0;
	categories["complex"] = 0;
	categories["untestable"] = 0;
   	categories["total"] = 0;
	
	for (unitSize <- unitSizesPerMethod) {
	
		//CC Risk evaluation table from paper "A Pratical Model for Measuring Maintanability"
		if (unitSize in [1..11]) {
			categories["low"] += unitSize;
		} else if (unitSize in [11..21]) {
			categories["moderate"] += unitSize;
		} else if (unitSize in [21..51]) {
			categories["complex"] += unitSize;
		} else if (unitSize > 50) {
			categories["untestable"] += unitSize;
		}
		
		categories["total"] += unitSize;
	}
	
	return categories;
}
*/