
class Layer implements Cloneable{
  
  Set<Face> faces;
  List<Edge> edges;
  Set<Vertex> vertices;
  
  Layer() {
    this(new HashSet<>(), new ArrayList<>());
  }

  Layer(Set<Face> faces, List<Edge> edges) {
    this.faces = faces;
    this.edges = edges;
  }
  
  Layer(Layer other) {
    try {
      faces = (Set<Face>) deepClone(other.faces);
      edges = (List<Edge>) deepClone(other.edges);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }  
  }

  void display(PGraphics g, Texture front, Texture back, color border) {
    g.stroke(border); 
    g.noFill();
    g.beginShape();

    for (Edge edge : edges) {
      Vertex v = edge.start;
      g.vertex(v.pos.x, v.pos.y, v.uv.x, v.uv.y);
      //edge.display(g);
    }
    g.endShape(CLOSE);
    g.noStroke();
    
    for (Face face : faces) {
      face.display(g, front, back);  
    }
  }
  
  //void addFace(Face face) {
  //  faces.add(face);  
  //}

  //void addEdge(Edge edge) {
  //  edges.add(edge);  
  //}
  
  void adjustCrease(Line crease) {
    Set<Vertex> fixedVerts = getFixedVertices();
    List<Vertex> crossedVerts = new ArrayList<>();
    
    for (Vertex vertex : fixedVerts) {
      if (crease.liesToRight(vertex.pos)) {
        crossedVerts.add(vertex);
      }
    }
    if (crossedVerts.isEmpty()) {
      return;  
    }
    if (crossedVerts.size() == 1) {
      crease.origin.set(crossedVerts.get(0).pos);
      return;
    }
    if (crossedVerts.size() > 2) {
      Collections.sort(crossedVerts, Comparator.comparingDouble(v -> crease.distance(v.pos).mag()));  
      crossedVerts.subList(2, crossedVerts.size()).clear();
    }
    Collections.sort(crossedVerts, Comparator.comparingDouble(v -> crease.tDistance(v.pos)));
    crease.origin.set(crossedVerts.get(0).pos);
    crease.direction.set(crossedVerts.get(1).getPos().sub(crossedVerts.get(0).pos).normalize());
  }
  
  Set<Vertex> getFixedVertices() {
    Set<Vertex> vertices = new HashSet<>();
    
    for (Edge edge : edges) {
      if (edge.foldsDown) {
        vertices.add(edge.start);
        vertices.add(edge.end);
      }
    }    
    return vertices;
  }
  
  Layer flip(Line crease) {
    for (Edge edge : edges) {
      edge.flip(crease);  
    }
    for (Face face : faces) {
      face.flip(crease);
    }
    return this;
  }
  
  Pair<Layer, Layer> fold(Line crease) {
    Pair<List<Edge>, List<Edge>> newLayerEdges = calcDividedEdges(crease);
    
    if (null == newLayerEdges) {
      //returns itself flipped/unflipped if the line does noth intersecti with layer directly
      if (crease.liesToRight(edges.get(0).start.pos)) {
        return new Pair<>(null, this.flip(crease));
      }else {
        return new Pair<>(this, null);
      }
    }
    Pair<Set<Face>, Set<Face>> newLayerFaces = calcDividedFaces(crease);
    return new Pair<>(
        new Layer(newLayerFaces.first, newLayerEdges.first),
        new Layer(newLayerFaces.second, newLayerEdges.second).flip(crease));
  }
  
  private Pair<Set<Face>, Set<Face>> calcDividedFaces(Line crease) {
    Set<Face> facesLeft = new HashSet<Face>();
    Set<Face> facesRight = new HashSet<Face>();
    
    for (Face face : faces) {
      Set<Face> subdivisions = face.subdivide(crease);
      
      for (Face newFace : subdivisions) {
        if (crease.liesToRight(newFace.getMid())) {
          facesRight.add(newFace);
        }else {
          facesLeft.add(newFace);
        }
      }
    }
    return new Pair<>(facesLeft, facesRight);
  }
  
  private Pair<List<Edge>, List<Edge>> calcDividedEdges(Line crease) {
    Vertex closeInters = null;
    Vertex farInters = null;
    int closeIndex = -1;
    int farIndex = -1;
    
    for (int i = 0; i < edges.size(); ++i) {
      Edge edge = edges.get(i);
      Vertex intersection = edge.intersect(crease);
      
      if (null == intersection) {
        continue;  
      }
      if (crease.liesToRight(edge.start.pos)) {
        closeInters = intersection;
        closeIndex = i;
      } else {
        farInters = intersection;  
        farIndex = i;
      }
    }
    if (-1 == closeIndex || -1 == farIndex) {
      return null;
    }
    return new Pair<>(
        createSubPolygon(closeIndex, farIndex, closeInters, farInters),
        createSubPolygon(farIndex, closeIndex, farInters, closeInters));
  }
  
  /**
    * Calculates edges of left or right side of the folded layer.
    * Starts at first vertex and iterates clockwise to last vertex to collect all edges that form the outline of the subdivision.
    */
  private List<Edge> createSubPolygon(int startIndex, int endIndex, Vertex first, Vertex last) {
    List<Edge> polygon = new ArrayList<>();
    polygon.add(new Edge(first, edges.get(startIndex).end));
    
    int edgeCount = edges.size();
    int distance = (endIndex + edgeCount - startIndex) % edgeCount;
    
    for (int i = startIndex+1; i < startIndex + distance; ++i) {
      polygon.add(edges.get(i % edgeCount).clone());  
    }
    polygon.add(new Edge(edges.get(endIndex).start, last));
    Edge newEdge = new Edge(last, first);
    newEdge.foldsUp = true;
    polygon.add(newEdge);
    return polygon;
  }
  
  @Override
  public Layer clone() {
    return new Layer(this);
  }
}
