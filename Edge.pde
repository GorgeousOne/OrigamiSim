class Edge implements Cloneable {
  
  Vertex start;
  Vertex end;
  boolean foldsDown;
  boolean foldsUp;
  
  Edge(Vertex start, Vertex end) {
    this.start = start.clone();
    this.end = end.clone();
  }
  
  Edge(Edge other) {
    start = other.start.clone();
    end = other.end.clone();
    foldsDown = other.foldsDown;
    foldsUp = other.foldsUp;
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
  
  /*
    theorectically start and end should be swapped so layer outlines always turn clockwise
    they don't and I thought this would break the layer folding algorithm
    but it doesnt
  */
  void flip(Line crease) {
    start.flip(crease);
    end.flip(crease);
    
    if (foldsDown || foldsUp) {
      foldsDown = !foldsDown;
      foldsUp = !foldsUp;
    }
  }
  
  Vertex point(float t) {
    Vertex v = start.clone();
    v.pos.add(getDir().mult(t));
    v.uv.add(getUvDir().mult(t));
    return v;
  }
  
  void display(PGraphics g) {
    g.beginShape(LINES);
    g.stroke(0);
    g.vertex(start.pos.x, start.pos.y);
    g.stroke(255, 0, 0);
    g.vertex(end.pos.x, end.pos.y);
    g.endShape();
  }
    
  @Override
  public Edge clone() {
    return new Edge(this);
  }
}
