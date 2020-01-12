module Testing

import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import Complexities;

loc projectLocation = |project://Jabberpoint|;

public Resource createProject(/*loc project*/) {
	return getProject(projectLocation);
}

public set[loc] getJavaFiles(Resource project) {
	return { f | /file(f) <- project, f.extension == "java"};
}

public void getMethods() {
	loc projectLocation = |project://Jabberpoint|;
    M3 model = createM3FromEclipseProject(projectLocation);
    rel[loc loc1,loc loc2] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+method" || x.scheme=="java+constructor"};
	println("#methods = <methods.loc2>");
    return methods;
}

public void getMethods2(/*loc project*/) {
	loc PROJECT = |project://Jabberpoint|;
	M3 model = createM3FromEclipseProject(PROJECT); 
    rel[loc,loc] constructors =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+constructor"};
    rel[loc,loc] methods =  { <x,y> | <x,y> <- model.declarations, x.scheme=="java+method"};
    rel[loc,loc] submethods = { <x,y> | <x,y> <- model.containment};
    println("constructors = <size(constructors)>");
    println("methods = <size(methods)>");
    println("submethods = <size(submethods)>");
	tuple[loc name,loc location] method = <|java+method:///Presentation/prevSlide()|,|project://Jabberpoint/src/Presentation.java|(1662,186,<61,1>,<66,2>)>;
    Declaration ast = createAstFromFile(method.name, true);
    println("<ast>");
}

public void /*list[Statement]*/ getMethodStatements(/*M3 model*/) {
	loc PROJECT = |project://Jabberpoint|;
	M3 model = createM3FromEclipseProject(PROJECT); 
    list[Statement] methodStatements = [];

    for(file <- files(model.containment)) {
        Declaration fileAST = createAstFromFile(file, false);

        visit(fileAST) {
            case \constructor(_,_,_,impl): {
                methodStatements += impl;
            }
            case \method(_,_,_,_,impl): {
                methodStatements += impl;
            }
        }
    }
    println({s | s <- methodStatements});	
//    return methodStatements;
}   


//werkt goed om method locations te bepalen
public void getMethodImpl() {
	loc projectLocation = |project://Jabberpoint|;
	Resource projectR = getProject(projectLocation);
	set[loc] javafiles = { f | /file(f) <- projectR, f.extension == "java"}; 
	print("#files = ");
	println(size(javafiles));

	set[loc] methodLocations = {};
	for (loc file <- javafiles) {
		Declaration ast = createAstFromFile(file, false);
		visit(ast) {
			case \method(a,methodName,c,d,impl): {
				methodLocations += impl.src;
			}
			case \constructor(methodName,c,d,impl): {
				methodLocations += impl.src;
			}
		}
	}
	println("#locations = <methodLocations>");
}                

//werkt goed om method locations te bepalen
public void getMethodLocations() {
	loc projectLocation = |project://Jabberpoint|;
	Resource projectR = getProject(projectLocation);
	set[loc] javafiles = { f | /file(f) <- projectR, f.extension == "java"}; 
	print("#files = ");
	println(size(javafiles));

	set[loc] methodLocations = {};
	for (loc file <- javafiles) {
		Declaration ast = createAstFromFile(file, false);
		visit(ast) {
			case \method(a,methodName,c,d,impl): {
				methodLocations += impl.src;
			}
			case \constructor(methodName,c,d,impl): {
				methodLocations += impl.src;
			}
		}
	}
//	println("#locations = <methodLocations>");
}

public void testComplexities() {
	set[ComplexityInformation] cis = calculateComplexities(projectLocation);
	println("\nDetails on Complexities:");
	for (ci <- cis) {
		print(ci);
	}
}

public rel[loc, Statement] getMethodsAST(set[Declaration] decls) {
	
   //set[Declaration] decls = createAstsFromFiles(bestanden, false);
   rel[loc, Statement] result = [];
   visit (decls) {
      case \method(_, _, _, _, impl): result += <m@src, impl>;
      case \constructor(_, _, _, impl): result += <c@src, impl>;
   }
   return(result);
}