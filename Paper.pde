
class Paper {  
  List<Vertex> vertices;
  LinkedList<Set<Face>> layers;
  
  Texture front;
  Texture back;
  color border;
  boolean isFlipped;
  
  Paper(Paper other) {
    this.front = other.front;
    this.back = other.back;
    this.border = other.border;
    
    try {
      vertices = (List<Vertex>) deepClone(other.vertices);
      layers = (LinkedList<Set<Face>>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size, Texture front, Texture back, color border) {
      this.vertices = new ArrayList<Vertex>();
      this.layers = new LinkedList<Set<Face>>();
      this.front = front;
      this.back = back;
      this.border = border;
      createSquare(size);
  }
  
  void createSquare(float size) {
    vertices.add(new Vertex(-size/2, -size/2, 0, 0));
    vertices.add(new Vertex( size/2, -size/2, 1, 0));
    vertices.add(new Vertex( size/2,  size/2, 1, 1));
    vertices.add(new Vertex(-size/2,  size/2, 0, 1));
    layers.add(new HashSet<Face>(Arrays.asList(
        new Face(vertices.get(0), vertices.get(1), vertices.get(2)),
        new Face(vertices.get(0), vertices.get(2), vertices.get(3)))));
  }
  
  void flip() {
     
  }
  
  void display(PGraphics g) {

    g.noFill();
    
    for (Set<Face> layer : layers) {
      g.stroke(border);
      for (Face face : layer) {
        face.display(g);  
      }
      g.noStroke();
      for (Face face : layer) {
        face.display(g, front, back);  
      }
    }
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
    
    for (Vertex vertex : vertices) {
      if (crease.liesToRight(vertex.pos)) {
        vertex.pos.set(crease.mirror(vertex.pos));
      }
    }
  }
  
  void addFace(Face face, int layer, Map<Integer, Set<Face>> layerMap) {
    layerMap.putIfAbsent(layer, new HashSet<Face>());
    layerMap.get(layer).add(face);    
  }
  
  @Override
  public Paper clone() {
    return new Paper(this);
  }
}
