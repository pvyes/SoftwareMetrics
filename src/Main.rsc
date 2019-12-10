module Main

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

public void main() {
	loc PROJECT = |project://SmallSQL-master/|;
	Resource project = getProject(PROJECT);
	set[loc] javafiles = { f | /file(f) <- project, f.extension == "java"};
	
	
	print("# of java files = ");
	println(size(javafiles));
}
