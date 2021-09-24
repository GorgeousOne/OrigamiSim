
class Line {
  PVector origin;
  PVector direction;
  
  Line(PVector origin, PVector direction) {
    this.origin = origin.copy();
    this.direction = direction.copy().normalize();
  }
  
  PVector getOrigin() {
    return origin.copy();  
  }
  
  PVector getDir() {
    return direction.copy();
  }
  
  PVector intersect(Line other) {
    PVector normal = other.direction.cross(new PVector(0, 0, 1));
    float dirsDotProduct = this.direction.dot(normal);
    
    //returns if lines are parallel
    if (dirsDotProduct == 0) {
      return null;
    }
    float delta = other.getOrigin().sub(this.origin).dot(normal) / dirsDotProduct;
    return point(delta);
  }
  
  PVector point(float t) {
    return getOrigin().add(getDir().mult(t));
  }
  
  /**
  * returns true if a point lies on the right side of the line viewed along the line direction
  */
  boolean liesToRight(PVector p) {
    PVector dist = p.copy().sub(origin);
    return turnsToRight(direction, dist);
  }
  
  PVector mirror(PVector p) {
    PVector normal = direction.cross(new PVector(0, 0, 1));
    PVector plumbBobPoint = intersect(new Line(p, normal));
    
    if (null == plumbBobPoint) {
      return p.copy();  
    }
    PVector dist = p.copy().sub(plumbBobPoint);
    return plumbBobPoint.sub(dist);
  }
}

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
  public Vertex clone() {
    return new Vertex(this);
  }
}
class Edge {
  
  Vertex start;
  Vertex end;
  
  Edge(Vertex start, Vertex end) {
    this.start = start.clone();
    this.end = end.clone();
  }
  
  PVector getDir() {
    return end.getPos().sub(start.pos);  
  }
  
  PVector getUvDir() {
    return end.getUV().sub(start.uv); 
  }
  
  float length() {
    return start.pos.dist(end.pos);  
  }
  
  Vertex intersect(Line line) {
    PVector normal = line.getDir().cross(new PVector(0, 0, 1));
    float dirsDotProduct = getDir().dot(normal);
    
    //returns if lines are parallel
    if (dirsDotProduct == 0) {
      return null;
    }
    float delta = line.getOrigin().sub(start.pos).dot(normal) / dirsDotProduct;
    return delta < 0 || delta > 1 ? null : point(delta);
  }
  
  Vertex point(float t) {
    Vertex v = start.clone();
    v.pos.add(getDir().mult(t));
    v.uv.add(getUvDir().mult(t));
    return v;
  }
  
  //void display() {
  //  line(start.pos.x, start.pos.y, end.pos.x, end.pos.y);
  //}
    
  @Override
  public Edge clone() {
    return new Edge(start.clone(), end.clone());
  }
}
