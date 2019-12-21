module Complexity

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import util::Resources;

alias ComplexityInformation = tuple[loc location,str name ,int complexity, Statement implementation];

/**
 * param projectlocation
 * return a set of tuples with file location, method name and complexity number.
 */
public set[ComplexityInformation] calculateComplexities(loc project) {
	Resource projectR = getProject(project);
	set[loc] javafiles = { f | /file(f) <- projectR, f.extension == "java"};
//	print("#files = ");
//	println(size(javafiles));
	set[ComplexityInformation] complexities = {};
	for (loc file <- javafiles) {
		complexities += calculateMethodComplexity(file);
	}
//	println(size(complexities));
	return complexities;
}
/*
public list[tuple[loc,str,int]] getMethodInformation(loc file) {
	Declaration ast = createAstFromFile(file, false);
	list[tuple[loc,str,int]] methodComplexities = [];
	visit(ast) {
		case \method(t, name, d, e, impl): {
			int cCount = calculateMethodComplexity(\method(t, name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <file ,name, cCount>;
			methodComplexities += methodComplexity;
//			FileLineInformation volume = countLinesOfCodePerFile(file, \method(t, name,d,e,impl));
//			println(volume);
   	}
		case \constructor(name,d,e,impl): {
			int cCount = calculateMethodComplexity(\constructor(name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <file ,name, cCount>;
			methodComplexities += methodComplexity;
    	}
    }
	return methodComplexities;
}
*/
/**
 *Calculates the complexities of the methods of a file
 *param location file
 *return a set of tuples containing the location of the file, the method's name and its complexity set[<location,name,complexity>]
 */
public set[tuple[loc file, str methodName , int mc]] calculateMethodComplexityDRAFT(loc file) {
	Declaration ast = createAstFromFile(file, false);
	set[tuple[loc,str,int]] methodComplexities = {};
	visit(ast) {
		case \method(t, name, decls, e, impl): {
			int cCount = calculateMethodComplexity(\method(t, name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <file ,name, cCount>;
			methodComplexities += methodComplexity;
   	}
		case \constructor(name,d,e,impl): {
			int cCount = calculateMethodComplexity(\constructor(name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <file ,name, cCount>;
			methodComplexities += methodComplexity;
    	}
    }
	return methodComplexities;
}

public set[ComplexityInformation] calculateMethodComplexity(loc file) {
	Declaration ast = createAstFromFile(file, false);
	set[tuple[loc,str,int,Statement]] methodComplexities = {};
	visit(ast) {
		case \method(t, name, d, e, impl): {
			int cCount = calculateMethodComplexity(\method(t, name,d,e,impl));			
			tuple[loc file, str methodName , int mc, Statement implementation] methodComplexity = <file ,name, cCount, impl>;
			methodComplexities += methodComplexity;
   	}
		case \constructor(name,d,e,impl): {
			int cCount = calculateMethodComplexity(\constructor(name,d,e,impl));			
			tuple[loc file, str methodName , int mc, Statement implementation] methodComplexity = <file ,name, cCount, impl>;
			methodComplexities += methodComplexity;
    	}
    }
	return methodComplexities;
}
/**
 * Calculates the cyclomatic complexity of one method.
 * param a declaration (method or constructor)
 * return the complexity.
 */
public int calculateMethodComplexity(Declaration method) {
	int complexity = 1;
	visit(method) { 		 
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

public str toString(ComplexityInformation ci) {
	loc l = ci.location;
	str s = l.path;
	s += "\t<ci.name>";
	s += "\t<ci.complexity>";
	s += "\n";
	return s;
}