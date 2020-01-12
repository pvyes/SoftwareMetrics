module Complexities

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import util::Resources;

import lang::java::m3::Core;

alias ComplexityInformation = tuple[loc location,str name ,int complexity];

int i = 0;
/**
 * param projectlocation
 * return a list of tuples with file location, method name and complexity number.
 */
public set[ComplexityInformation] calculateComplexities(loc project) {
	Resource projectR = getProject(project);
	set[loc] javafiles = { f | /file(f) <- projectR, f.extension == "java"}; 
	set[ComplexityInformation] complexities = {};
	for (loc file <- javafiles) {
		complexities += calculateMethodComplexity(file);
	}
//println("#methods in complexity = <i>");
	return complexities;
}

public set[ComplexityInformation] calculateMethodComplexity(loc file) {
	Declaration ast = createAstFromFile(file, false);
	set[ComplexityInformation] methodComplexities = {};
	int cCount;
	str name;
	loc location;	
	
	visit(ast) {
		case \method(a,methodName,c,d,impl): {
		i += 1;
			location = impl.src;
			name = methodName;
			cCount = calculateMethodComplexity(\method(a,name,c,d,impl));
			methodComplexities += <location,name,cCount>;
		}
		case \constructor(methodName,c,d,impl): {
		i += 1;
			location = impl.src;
			name = methodName;
			cCount = calculateMethodComplexity(\constructor(name,c,d,impl));
			methodComplexities += <location,name,cCount>;
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
    	}
    	case \while(cond, _): {
    		str line = readFile(cond.src);
    		int orConditions = countOrConditions(line);
    		complexity += (1 + orConditions);
        }
	   	case \do(_, cond): {   	
    		str line = readFile(cond.src);
    		int orConditions = countOrConditions(line);
    		complexity += (1 + orConditions);
    	}
 	   	case \case(_): {
    		complexity += 1;
    	}   
    	case \catch(_,_): {
    		complexity += 1;
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

public str toCSV(set[ComplexityInformation] cis) {
	str header = "location,name,complexity\n";	
	str s = "";
	int i = 1;
	for (ci <- cis) {
		loc l = ci.location;
		s += l.path;
		s += ",<ci.name>";
		s += ",<ci.complexity>";
		s += "\n";
	}
	return header + s;
}