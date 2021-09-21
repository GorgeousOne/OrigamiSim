
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
  
  /**
  * returns true if a point lies on the right side of the line viewed along the line direction
  */
  boolean liesToRight(PVector p) {
    PVector dist = p.copy().sub(origin);
    return turnsToRight(direction, dist);
  }
}

class LineSegment {
  
  PVector start;
  PVector end;
  
  LineSegment(PVector start, PVector end) {
    this.start = start.copy();
    this.end = end.copy();
  }
  
  PVector getDir() {
    return end.copy().sub(start);  
  }
  
  PVector intersect(Line line) {
    PVector normal = line.getDir().cross(new PVector(0, 0, 1));
    float dirsDotProduct = getDir().dot(normal);
    
    //returns if lines are parallel
    if (dirsDotProduct == 0) {
      return null;
    }
    float delta = line.getOrigin().sub(start).dot(normal) / dirsDotProduct;
    return delta < 0 || delta > 1 ? null :  point(delta);
    //return point(delta);
  }
  
  PVector point(float t) {
    return start.copy().add(end.copy().sub(start).mult(t));
  }
  
  void display() {
    line(start.x, start.y, end.x, end.y);
  }
    
  @Override
  public LineSegment clone() {
    return new LineSegment(start, end);
  }
}
