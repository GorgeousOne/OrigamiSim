float epsilon = 0.001;

class Face {
  boolean isFlipped;
  Vertex v0;  
  Vertex v1;  
  Vertex v2;  
  Edge edge0;
  Edge edge1;
  Edge edge2;

  Face(Vertex v0, Vertex v1, Vertex v2) {
    this(v0, v1, v2, false);
  }

  Face(Vertex v0, Vertex v1, Vertex v2, boolean isFlipped) {
    this.isFlipped = isFlipped;
    
    if (turnsToRight(v2.getPos().sub(v1.pos), v1.getPos().sub(v1.pos))) {
      this.v0 = v0.clone();
      this.v1 = v1.clone();
      this.v2 = v2.clone();
    }else {
      this.v0 = v0.clone();
      this.v1 = v2.clone();
      this.v2 = v1.clone();
    }
    edge0 = new Edge(v0, v1);
    edge1 = new Edge(v1, v2);
    edge2 = new Edge(v2, v0);
  }
  
  PVector getMid() {
    return v0.getPos().add(v1.pos).add(v2.pos).mult(1/3f);  
  }

  void displayShadow(PGraphics g) {
    displayShadowEdge(edge0, g);
    displayShadowEdge(edge1, g);
    displayShadowEdge(edge2, g);
  }
  
  void displayShadowEdge(Edge edge, PGraphics g) {
    PVector origin = edge.start.getPos();
    PVector dir = edge.getDir();    
    PVector normal = dir.cross(new PVector(0, 0, 1)).normalize();
    float shadowRange = 10;
  
    //gives edge information to shader, screen space has inverted y
    shadow.set("origin", origin.x + width/2f, height/2f - origin.y);
    shadow.set("dir", dir.x, -dir.y);
    shadow.set("normal", normal.x, -normal.y);
    shadow.set("radius", shadowRange);
    shadow.set("color", 0, 0, 0, 0.5);
    g.shader(shadow);
    g.strokeWeight(3*shadowRange);
    g.stroke(0);
    g.line(origin.x, origin.y, edge.end.pos.x, edge.end.pos.y);
    g.resetShader();
  }

  void display(PGraphics g, Texture front, Texture back) {
    g.beginShape();
    
    if (isFlipped) {
      back.apply(g);  
    }else {
      front.apply(g);
    }    
    g.vertex(v0.pos.x, v0.pos.y, v0.uv.x, v0.uv.y);
    g.vertex(v1.pos.x, v1.pos.y, v1.uv.x, v1.uv.y);
    g.vertex(v2.pos.x, v2.pos.y, v2.uv.x, v2.uv.y);
    g.endShape(CLOSE);    
  }

  //boolean contains(PVector point) {
  //  float d1 = this.signFunc(point, this.p0, this.p1);
  //  float d2 = this.signFunc(point, this.p1, this.p2);
  //  float d3 = this.signFunc(point, this.p2, this.p0);
  //  boolean hasNegativeCoordinate = d1 < epsilon || d2 < epsilon || d3 < epsilon;
  //  boolean hasPositiveCoordinate = d1 > epsilon || d2 > epsilon || d3 > epsilon;
  //  return !(hasNegativeCoordinate && hasPositiveCoordinate);
  //}
  
  //float signFunc(PVector p, PVector v0, PVector v1) {
  //    return (p.x - v1.x) * (v0.y - v1.y) - (v0.x - v1.x) * (p.y - v1.y);  
  //}
  
  Set<Face> subdivide(Line crease) {    
    Set<Face> divisions = new HashSet<Face>();
    Vertex inters0 = edge0.intersect(crease);
    Vertex inters1 = edge1.intersect(crease);
    Vertex inters2 = edge2.intersect(crease);
    
    //no intersection with face
    if (null == inters0 &&
        null == inters1 &&
        null == inters2) {
      divisions.add(this.clone());  
      return divisions;
    }
    if (null != inters0 && null != inters1) {
      divisions.add(new Face(inters0, v1, inters1, isFlipped));
      divisions.addAll(triangulateQuad(inters0, inters1, v2, v0));
    } else if (null != inters1 && null != inters2) {
      divisions.add(new Face(inters1, v2, inters2, isFlipped));
      divisions.addAll(triangulateQuad(inters1, inters2, v0, v1));      
    } else {
      divisions.add(new Face(inters2, v0, inters0, isFlipped));
      divisions.addAll(triangulateQuad(inters2, inters0, v1, v2));      
    }
    return divisions;
  }
  
  Set<Face>triangulateQuad(Vertex p0, Vertex p1, Vertex p2, Vertex p3) {
    float disuv1 = p0.pos.dist(p2.pos);
    float disuv2 = p1.pos.dist(p3.pos);
    
    if (disuv1 < disuv2) {
      return new HashSet<>(Arrays.asList(
          new Face(p0, p1, p2, isFlipped),
          new Face(p0, p2, p3, isFlipped)));
    } else {
      return new HashSet<>(Arrays.asList(
          new Face(p1, p2, p3, isFlipped),
          new Face(p1, p3, p0, isFlipped)));
    }
  }
  
  void flip(Line crease) {
    isFlipped = !isFlipped;
    v0.pos.set(crease.mirror(v0.pos));
    v1.pos.set(crease.mirror(v1.pos));
    v2.pos.set(crease.mirror(v2.pos));
    edge0 = new Edge(v0, v1);
    edge1 = new Edge(v1, v2);
    edge2 = new Edge(v2, v0);
  }
  
  @Override
  public Face clone() {
    return new Face(v0, v1, v2, isFlipped);
  }
  
  @Override
  public String toString() {
    return "[" + v0 + "," + v1 + "," + v2 + "]\n";  
  }
}
