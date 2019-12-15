module Complexity

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

public int calculateComplexities() {
	
}



/**
 * Calculates the cyclomatic complexity of one method.
 * TODO param a method
 * return the complexity.
 */
public int calculateComplexity() {
	//begin with one method from Distinct 2
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);	
//	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};
//	loc file = |project://SmallSQL-master/src/main/java/smallsql/database/Distinct2.java|;
//	set[Declaration] asts = createAstsFromFiles(javafiles, false);
	set[Declaration] asts = createAstsFromFiles({|project://SmallSQL-master/src/main/java/smallsql/database/Distinct2.java|}, false);
print("size asts =  ");
println(size(asts));

//	M3 model = createM3FromEclipseFile(|project://SmallSQL-master/src/main/java/smallsql/database/Distinct2.java|);
/*	methods =  { <x,y> | <x,y> <- model.containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor" 
                       };
   telMethoden = { <a, size(methoden[a])> | a <- domain(methoden) };
*/ 
	int complexity = 1;   
	visit(asts) {  
    	case \if(cond, _): {
    		str line = readFile(cond.src);
    		int orConditions = countOrConditions(line);
    		complexity += (1 + orConditions);
//        	println("if-or-condition = " + line + ": <orConditions>");
//			println("count = <complexity>");
    	}
    	case \while(cond, _): {
    		str line = readFile(cond.src);
    		int orConditions = countOrConditions(line);
    		complexity += (1 + orConditions);
//        	println("while-or-condition = " + line + ": <orConditions>");
//			println("count = <complexity>");
        }
	   	case \do(_, cond): {
    		str line = readFile(cond.src);
    		int orConditions = countOrConditions(line);
    		complexity += (1 + orConditions);
//        	println("do-condition = <line>");
//			println("count = <complexity>");
    	}
 	   	case \case(_): {
    		complexity += 1;
//			println("count = <complexity>");
    	}   
    	case \catch(_,_): {
    		complexity += 1;
//			println("count = <complexity>");
    	}	
	}
	println("complexity = <complexity>");
	return complexity;
}

public int countOrConditions(str text) {
	int count = 0; 
	if (text == "") {
		return 0;
	}
	while (/^<begin:.*>\|{2}<end:.*>/s := text) {
		count += 1;
		text = begin + end;
	}
	//println(count);
	return count;
}

public int countOrConditions(str text) {
	int count = 0; 
	if (text == "") {
		return 0;
	}
	while ((/^<begin:.*>\|\|<end:.*>/s := text)) {
		count += 1;
		text = begin + end;
	}
	//println(count);
	return count;
}
