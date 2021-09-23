
class Paper {  
  List<Vertex> vertices;
  Map<Integer, Set<Face>> layers;
  Texture front;
  Texture back;
  color border;
  
  Paper(Paper other) {
    this.front = other.front;
    this.back = other.back;
    this.border = other.border;
    
    try {
      vertices = (List<Vertex>) deepClone(other.vertices);
      layers = (HashMap<Integer, Set<Face>>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size, Texture front, Texture back, color border) {
      vertices = new ArrayList<Vertex>();
      layers = new HashMap<Integer, Set<Face>>();
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
    layers.put(0, new HashSet<Face>(Arrays.asList(
        new Face(vertices.get(0), vertices.get(1), vertices.get(2)),
        new Face(vertices.get(0), vertices.get(2), vertices.get(3)))));
  }

  void display(PGraphics g) {
    List<Integer> layerKeys = new ArrayList<Integer>(layers.keySet());
    Collections.sort(layerKeys);
    g.noFill();
    
    for (int layer : layerKeys) {
      g.stroke(border);
      for (Face face : layers.get(layer)) {
        face.display(g);  
      }
      g.noStroke();
      for (Face face : layers.get(layer)) {
        face.display(g, front, back);  
      }
    }
  }

  void fold(Line crease) {
    HashMap<Integer, Set<Face>> newLayers = new HashMap<Integer, Set<Face>>();
    
    int newLayerCount = layers.size() * 2;
    for (int layer : this.layers.keySet()) {
      for (Face face : this.layers.get(layer)) {
        Set<Face> subdivisions = face.subdivide(crease);
        
        for (Face newFace : subdivisions) {
          if (crease.liesToRight(newFace.getMid())) {
            newFace.flip(crease);
            addFace(newFace, newLayerCount - layer - 1, newLayers);
          }else {
            addFace(newFace, layer, newLayers);            
          }
        }
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
