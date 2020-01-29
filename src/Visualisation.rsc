module Visualisation

import vis::Figure;
import vis::Render;

 public void show() {

 	b = box(fillColor("red"), shrink(0.5));
 	e = ellipse(b, size(200,100), shrink(0.8), lineStyle("dot"));
 	render(higher());
 }
 	
 public bool intInput(str s){
	return /^[0-9]+$/ := s;
}

public Figure higher(){
	int H = 100;
    return vcat( [ textfield("<H>", void(str s){H = toInt(s);}, intInput),
	               box(width(100), vresizable(false), vsize(num(){return H;}), fillColor("red"))
	             ], shrink(0.5), resizable(false));
 }