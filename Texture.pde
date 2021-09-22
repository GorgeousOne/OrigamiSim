
//a texture to apply during polygon rendering
interface Texture {
  void apply();
}

class SolidFill implements Texture {     
  color solidFill;
  
  SolidFill(color solidFill) {
    this.solidFill = solidFill;  
  }
  
  void apply() {
    fill(solidFill);  
  }
}

class Graphic implements Texture {
  PImage tex;
  
  Graphic(PImage tex) {
    this.tex = tex;  
  }
  
  void apply() {
    texture(tex);
  }
}
