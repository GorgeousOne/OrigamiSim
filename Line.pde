
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
