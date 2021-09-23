
//a texture to apply during polygon rendering
interface Texture {
  void apply(PGraphics g);
}

class SolidFill implements Texture {     
  color solidFill;
  
  SolidFill(color solidFill) {
    this.solidFill = solidFill;  
  }
  
  void apply(PGraphics g) {
    g.fill(solidFill);  
  }
}

class Graphic implements Texture {
  PImage tex;
  
  Graphic(PImage tex) {
    this.tex = tex;  
  }
  
  void apply(PGraphics g) {
    g.texture(tex);
  }
}
