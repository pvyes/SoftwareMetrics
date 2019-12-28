module Complexities

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;
import util::Resources;

alias LocInfo = tuple[str locationUri,int offset,int length,int beginline,int begincolumn,int endline,int endcolumn];
alias ComplexityInformation = tuple[loc location,str name ,int complexity, LocInfo locInfo];
/**
 * param projectlocation
 * return a list of tuples with file location, method name and complexity number.
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
//	println("#complexities = <size(complexities)>");
	return complexities;
}

public set[ComplexityInformation] calculateComplexities2(/*loc project*/) {
	loc PROJECT = |project://Jabberpoint|;
	M3 model = createM3FromEclipseProject(PROJECT); 
//    rel[loc,loc] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+method" || x.scheme=="java+constructor"};
    rel[loc,loc] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+constructor"};
    rel[loc,loc] submethods = { <x,y> | <x,y> <- model.containment};
    println("methods = <methods>");
    set[ComplexityInformation] cis = {};
    tuple[loc,loc] example = toList(methods)[0];
    for (<m,l> <- methods) {  
    	cis = calculateMethodComplexity(l);  
	}                   
//	println("#cis = <size(cis)>");
	return cis;
}

public set[ComplexityInformation] calculateMethodComplexity(loc file) {
//println(readFile(file));
	Declaration ast = createAstFromFile(file, false);
//	println(ast);
	set[ComplexityInformation] methodComplexities = {};
	int cCount;
	str name;
	LocInfo locInfo;
int i = 0;	
	
	visit(ast) {
		case \method(a,methodName,c,d,impl): {
		i += 1;
			locInfo = getLocationInformation(impl);
			name = methodName;
			cCount = calculateMethodComplexity(\method(a,name,c,d,impl));
			methodComplexities += <file,name,cCount,locInfo>;
		}
		case \constructor(methodName,c,d,impl): {
		i += 1;
			locInfo = getLocationInformation(impl);
			name = methodName;
			cCount = calculateMethodComplexity(\constructor(name,c,d,impl));
			methodComplexities += <file,name,cCount,locInfo>;
		}
	}
//	println("after visit: i = <i>");
	return methodComplexities;
}

/*
public ComplexityInformation countComplexityPerFile(m,l) {
	println(m);
	println(readFile(l));
	calculateMethodComplexity(l);
	return <l,"name",0>;
}
*/
/**
 *Calculates the complexities of the methods of a file
 *param location file
 *return a list of tuples containing the location of the file, the method's name and its complexity list[<location,name,complexity>]
 */ 
/* 
public list[ComplexityInformation] calculateMethodComplexity(loc file) {
	Declaration d = createAstFromString(file, readFile(file), false);
	println(d);
	rel[ComplexityInformation] methodComplexities = {};
	visit(d) {
		case \return(): {
			println("visit");
			int cCount = calculateMethodComplexity(\method(t, name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <ast.src ,name, cCount>;
			methodComplexities += methodComplexity;
   	}
		case \constructor(name,d,e,impl): {
			int cCount = calculateMethodComplexity(\constructor(name,d,e,impl));			
			tuple[loc file, str methodName , int mc] methodComplexity = <ast.src ,name, cCount>;
			methodComplexities += methodComplexity;
    	}
   }
	return methodComplexities;
}
*/
/**
 *Calculates the complexities of the methods of a file
 *param location file
 *return a list of tuples containing the location of the file, the method's name and its complexity list[<location,name,complexity>]
 */
/*public rel[ComplexityInformation] calculateMethodsComplexity(loc file) {
	Declaration ast = createAstFromFile(file, false);
	rel[ComplexityInformation] methodComplexities = {};
	visit(ast) {
		case \method(t, name, d, e, impl): {
			int cCount = calculateMethodComplexity(\method(t, name,d,e,impl));			
			ComplexityInformation methodComplexity = <ast.src ,name, cCount, impl>;
			methodComplexities += methodComplexity;
   		}
		case \constructor(name,d,e,impl): {
			int cCount = calculateMethodComplexity(\constructor(name,d,e,impl));			
			ComplexityInformation methodComplexity = <ast.src ,name, cCount, impl>;
			methodComplexities += methodComplexity;
    	}
    }
	return methodComplexities;
}
*/
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

public LocInfo getLocationInformation(Statement impl) {
	LocInfo locInfo;

			str implStr = toString(impl);
//			println(impl);
			if (/\|<location:.*?>\|<end:.*?\)>/ := implStr) {
//				println("end: <end>");
				bool regexFound = (/(\()<offset:.*?><end:\,.*>/ := end);		
//				println("end: <end>");
				bool regexFound2 = /\,<length:.*?>\,\<<end2:.*>/ := end;
//				println("end: <end2>");
				bool regexFound3 = /<beginline:.*?>\,<end3:.*>/ := end2;
//				println("end: <end3>");
				bool regexFound4 = /<begincolumn:.*?>\>\,\<<end4:.*>/ := end3;
//				println("end: <end4>");
				bool regexFound5 = /<endline:.*?>\,<end5:.*>/ := end4;
//				println("end: <end5>");
				bool regexFound6 = /<endcolumn:.*?>\><end6:.*>/ := end5;
//				println("end: <end4>");
								
/*				println("location: <location>");
				println("offset: <offset>");
				println("length: <length>");
				println("beginline: <beginline>");
				println("begincolumn: <begincolumn>");
				println("endline: <endline>");
				println("endcolumn: <endcolumn>");
*/						
				locInfo = <location, toInt(offset), toInt(length), toInt(beginline), toInt(begincolumn), toInt(endline), toInt(endcolumn)>; 
//				println(<locInfo>);
			}
			return locInfo;			
}