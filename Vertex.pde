import java.util.Objects;

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
  
  Vertex flip(Line crease) {
    pos.set(crease.mirror(pos));
    return this;
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
    return pos.dist(vertex.pos) < 0.01;
  }
  
  //have no idea how hashing should work. I want unique hashes for floats 
  @Override
  int hashCode() {
    final int h1 = Float.floatToIntBits(threshold(pos.x));
    final int h2 = Float.floatToIntBits(threshold(pos.y));
    return h1 ^ ((h2 >>> 16) | (h2 << 16));
  }
  
  @Override
  public Vertex clone() {
    return new Vertex(this);
  }
}

float threshold(float f) {
  return round(f * 1000) / 1000f;
}
