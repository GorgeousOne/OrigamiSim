float epsilon = 0.001;

class Face {
  boolean isFlipped;
  PVector p0;  
  PVector p1;  
  PVector p2;  
  LineSegment edge0;
  LineSegment edge1;
  LineSegment edge2;

  Face(PVector p0, PVector p1, PVector p2) {
    this(p0, p1, p2, false);
  }

  Face(PVector p0, PVector p1, PVector p2, boolean isFlipped) {
    this.isFlipped = isFlipped;
    this.p0 = p0.copy();
    this.p1 = p1.copy();
    this.p2 = p2.copy();
    
    if (turnsToRight(p2.copy().sub(p0), p1.copy().sub(p0))) {
      edge0 = new LineSegment(p0, p1);
      edge1 = new LineSegment(p1, p2);
      edge2 = new LineSegment(p2, p0);
    } else {
      edge0 = new LineSegment(p0, p2);
      edge1 = new LineSegment(p2, p1);
      edge2 = new LineSegment(p1, p0);
    }
  }
  
  PVector getMid() {
    return p0.copy().add(p1).add(p2).mult(1/3f);  
  }
  
  final color front = color(232, 245, 255);
  final color back = color(255, 240, 240);
  
  void display() {
    fill(isFlipped ? back : front);
    strokeWeight(2);
    stroke(0);
    
    beginShape();
    vertex(this.p0.x, this.p0.y);
    vertex(this.p1.x, this.p1.y);
    vertex(this.p2.x, this.p2.y);
    endShape(CLOSE);
  }

  boolean contains(PVector point) {
    float d1 = this.signFunc(point, this.p0, this.p1);
    float d2 = this.signFunc(point, this.p1, this.p2);
    float d3 = this.signFunc(point, this.p2, this.p0);
    boolean hasNegativeCoordinate = d1 < epsilon || d2 < epsilon || d3 < epsilon;
    boolean hasPositiveCoordinate = d1 > epsilon || d2 > epsilon || d3 > epsilon;
    return !(hasNegativeCoordinate && hasPositiveCoordinate);
  }
  
  float signFunc(PVector p, PVector v0, PVector v1) {
      return (p.x - v1.x) * (v0.y - v1.y) - (v0.x - v1.x) * (p.y - v1.y);  
  }
  
  Set<Face> subdivide(Line crease) {    
    Set<Face> divisions = new HashSet<Face>();
    PVector inters0 = edge0.intersect(crease);
    PVector inters1 = edge1.intersect(crease);
    PVector inters2 = edge2.intersect(crease);
    
    //no intersection with face
    if (null == inters0 &&
        null == inters1 &&
        null == inters2) {
      divisions.add(this);  
      return divisions;
    }
    if (null != inters0 && null != inters1) {
      divisions.add(new Face(inters0, p1, inters1));
      divisions.addAll(triangulateQuad(inters0, inters1, p2, p0));
    } else if (null != inters1 && null != inters2) {
      divisions.add(new Face(inters1, p2, inters2));
      divisions.addAll(triangulateQuad(inters1, inters2, p0, p1));      
    } else {
      divisions.add(new Face(inters2, p0, inters0));
      divisions.addAll(triangulateQuad(inters2, inters0, p1, p2));      
    }
    return divisions;
  }
  
  Set<Face>triangulateQuad(PVector p0, PVector p1, PVector p2, PVector p3) {
    float dist1 = p0.dist(p2);
    float dist2 = p1.dist(p3);
    
    if (dist1 < dist2) {
      return new HashSet<>(Arrays.asList(
          new Face(p0, p1, p2),
          new Face(p0, p2, p3)));
    } else {
      return new HashSet<>(Arrays.asList(
          new Face(p1, p2, p3),
          new Face(p1, p3, p0)));
    }
  }
  
  @Override
  public Face clone() {
    return new Face(p0, p1, p2);
  }
  
  @Override
  public String toString() {
    return "[" + p0 + "," + p1 + "," + p2 + "]\n";  
  }
}
