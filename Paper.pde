

class Paper {  
  List<PVector> vertices;
  List<Face> faces;
  List<LineSegment> edges;
  
  Paper(Paper other) {
    try {
      vertices = deepCopy(other.vertices);
      faces = deepClone(other.faces);
      edges = deepClone(other.edges);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size) {
      vertices = new ArrayList<PVector>();
      faces = new ArrayList<Face>();
      edges = new ArrayList<LineSegment>();
      createSquare(size);
  }
  
  void createSquare(float size) {
    vertices.add(new PVector(-size/2, -size/2));
    vertices.add(new PVector( size/2, -size/2));
    vertices.add(new PVector( size/2, size/2));
    vertices.add(new PVector(-size/2, size/2));
    faces.add(new Face(vertices.get(0), vertices.get(1), vertices.get(2)));
    faces.add(new Face(vertices.get(0), vertices.get(2), vertices.get(3)));
    createEdges();
  }
  
  void createEdges() {
    for (int i = 0; i < vertices.size(); ++i) {      
      edges.add(new LineSegment(vertices.get(i), vertices.get((i+1) % vertices.size())));
    }
  }
  
  void display() {
    for (Face face : faces) {
      face.display();  
    }
    //noFill();
    //strokeWeight(2);
    //stroke(0);

    //for (LineSegment edge : edges) {
    //  edge.display();  
    //}
  }
  
  boolean contains(PVector p) {
    for(Face face : faces) {      
      if (face.contains(p)) {
        return true;            
      }
    }
    return false;
  }
    
  void fold(Line crease, PVector vertex) {
    List<Face> newFaces = new ArrayList<Face>();
  
    for (Face face : faces) {
      newFaces.addAll(face.subdivide(crease));  
    }
    this.faces = newFaces;
  }
  
  @Override
  public Paper clone() {
    return new Paper(this);
  }
}
