module Figures

import analysis::graphs::Graph;
import Relation;
import vis::Figure;
import vis::Render;

// voorbeeld 1: graaf visualisatie

public Graph[str] mygraph = 
   { <"A", "B">, <"A", "D">, <"B", "D">
   , <"B", "E">, <"C", "B">, <"C", "E">, <"C", "F">
   , <"E", "D">, <"E", "F">
   };
  
public Figure showGraph(Graph[str] g) {
   nodes = [ box(text(s), id(s), size(60), fillColor("yellow"))
           | s <- carrier(g) 
           ];
   edges = [ edge(a, b, toArrow(ellipse(size(5))))
           | <a, b> <- g
           ];
   return graph(nodes, edges, hint("layered"), gap(50));
}
  
public void fig1() {
   render(showGraph(mygraph));
}

// voorbeeld 2: mouse over

public FProperty popup(str S) =
   mouseOver(box(text(S), fillColor("lightyellow"),grow(1.2),resizable(false)));

public void fig2() {
   render(box(size(50),fillColor("red"), shrink(0.5), popup("Hello")));
}

// voorbeeld 3: sliders and interaction

public Figure scaledbox() {
   int n = 100;
   Figure mySlider = scaleSlider(
      int () { return 0; }, // callback laagste waarde
      int () { return 200; }, // callback hoogste waarde
      int () { return n; }, // callback huidige selectie
      void (int s) { n = s; }, // callback bij verandering
      width(200));
   Figure myText = text(str () { return "n: <n>";});
   Figure myBox = computeFigure(Figure () {
      return box(text("size is <n>"), size(n), resizable(false)); });
   return vcat([ hcat([mySlider, myText],
      left(), top(), resizable(false)), myBox]);
}

public void fig3() {
   render(scaledbox());
}

public Figure comboTest(){
  str state = "A";
  return vcat([ combo(["A","B","C","D"], void(str s){ state = s;}),
                text(str(){return "Current state: " + state ;}, left())
              ]);
}

public void fig4() {
	render(comboTest());
}
