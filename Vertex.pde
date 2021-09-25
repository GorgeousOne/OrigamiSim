
class Vertex implements Cloneable{
  PVector pos;
  PVector uv;
  
  Vertex(float x, float y, float uvx, float uvy) {
    this.pos = new PVector(x, y);
    this.uv = new PVector(uvx, uvy);
  }
  
  Vertex(Vertex other) {
    this.pos = other.pos.copy();
    this.uv = other.uv.copy();
  }
  
  PVector getPos() {
    return pos.copy();
  }

  PVector getUV() {
    return uv.copy();
  }
  
  @Override
  public String toString() {
    return "\n" + pos.toString();
  }
  
  @Override
  boolean equals(Object other) {
      if (this == other) {
      return true;
    }
    if (!(other instanceof Vertex)) {
      return false;
    }
    Vertex vertex = (Vertex) other;
    return pos.dist(vertex.pos) < 0.001;
  }
  
  //@Override
  //int hashCode() {
  //  return pos.hashCode();
  //}
  
  @Override
  public Vertex clone() {
    return new Vertex(this);
  }
}
