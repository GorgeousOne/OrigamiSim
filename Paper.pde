
class Paper {  
  Set<Vertex> dragNodes;
  LinkedList<Set<Face>> layers;
  LinkedList<LinkedList<Vertex>> layerVerts;
  
  Texture front;
  Texture back;
  color border;
  boolean isFlipped;
  
  Paper(Paper other) {
    this.front = other.front;
    this.back = other.back;
    this.border = other.border;
    
    try {
      dragNodes = (Set<Vertex>) deepClone(other.dragNodes);
      layerVerts = (LinkedList<LinkedList<Vertex>>) deepClone(other.layerVerts);
      layers = (LinkedList<Set<Face>>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size, Texture front, Texture back, color border) {
      this.dragNodes = new HashSet<Vertex>();
      this.layers = new LinkedList<Set<Face>>();
      this.layerVerts = new LinkedList<LinkedList<Vertex>>();

      this.front = front;
      this.back = back;
      this.border = border;
      createSquare(size);
  }
  
  private void createSquare(float size) {
    LinkedList<Vertex> firstLayer = new LinkedList<Vertex>(Arrays.asList(
        new Vertex(-size/2, -size/2, 0, 0),
        new Vertex( size/2, -size/2, 1, 0),
        new Vertex( size/2,  size/2, 1, 1),
        new Vertex(-size/2,  size/2, 0, 1)));
    
    layers.add(new HashSet<Face>(Arrays.asList(
        new Face(firstLayer.get(0), firstLayer.get(1), firstLayer.get(2)),
        new Face(firstLayer.get(0), firstLayer.get(2), firstLayer.get(3)))));
    layerVerts.add(firstLayer);
    dragNodes.addAll(firstLayer);    
  }
  
  private void calcVertices() {
    dragNodes.clear();
    layerVerts.clear();
    
    for (Set<Face> layer : layers) {
      Set<Vertex> newLayerVerts = new HashSet<Vertex>();
      
      for (Face face : layer) {
        newLayerVerts.add(face.v0);
        newLayerVerts.add(face.v1);
        newLayerVerts.add(face.v2);
      }
      LinkedList<Vertex> hull = convexHull(new LinkedList<Vertex>(newLayerVerts));
      layerVerts.addLast(hull);
      dragNodes.addAll(hull);
    }
  }
  
  void flip() {
    Collections.reverse(layers);
    Line mid = new Line(new PVector(0, 0), new PVector(0, 1));
    
    for (Set<Face> layer : layers) {
      for (Face face : layer) {
        face.flip(mid);  
      }
    }
    calcVertices();
  }
  
  void display(PGraphics g) {
    Iterator<LinkedList<Vertex>> it = layerVerts.iterator();

    for (Set<Face> layer : layers) {
      displayHull(it.next(), g);
      g.noStroke();

      for (Face face : layer) {
        face.display(g, front, back);  
      }
    }
  }
  
  private void displayHull(List<Vertex> vertices, PGraphics g) {
    g.noFill();
    g.stroke(border);
    g.beginShape();
    
    for (Vertex v : vertices) {
      g.vertex(v.pos.x, v.pos.y);   
    }
    g.endShape(CLOSE);
  }
  
  void fold(Line crease) {
    LinkedList<Set<Face>> newLayers = new LinkedList<Set<Face>>();
    Iterator<Set<Face>> it = layers.descendingIterator();
    
    while(it.hasNext()) {
      Set<Face> layer = it.next();
      Set<Face> newBotLayer = new HashSet<Face>();
      Set<Face> newTopLayer = new HashSet<Face>();
      
      for (Face face : layer) {
        Set<Face> subdivisions = face.subdivide(crease);
        
        for (Face newFace : subdivisions) {
          if (crease.liesToRight(newFace.getMid())) {
            newFace.flip(crease);
            newTopLayer.add(newFace);
          }else {
            newBotLayer.add(newFace);
          }
        }
      }
      if (!newBotLayer.isEmpty()) {
        newLayers.addFirst(newBotLayer);  
      }
      if (!newTopLayer.isEmpty()) {
        newLayers.addLast(newTopLayer);
      }
    }
    this.layers = newLayers;
    calcVertices();
  }
  
  @Override
  public Paper clone() {
    return new Paper(this);
  }
}
