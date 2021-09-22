
class Paper {  
  List<PVector> vertices;
  Map<Integer, Set<Face>> layers;
  
  Paper(Paper other) {
    try {
      vertices = deepCopy(other.vertices);
      layers = (HashMap<Integer, Set<Face>>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size) {
      vertices = new ArrayList<PVector>();
      layers = new HashMap<Integer, Set<Face>>();
      createSquare(size);
  }
  
  void createSquare(float size) {
    vertices.add(new PVector(-size/2, -size/2));
    vertices.add(new PVector( size/2, -size/2));
    vertices.add(new PVector( size/2, size/2));
    vertices.add(new PVector(-size/2, size/2));
    layers.put(0, new HashSet<Face>(Arrays.asList(
        new Face(vertices.get(0), vertices.get(1), vertices.get(2)),
        new Face(vertices.get(0), vertices.get(2), vertices.get(3)))));
  }

  void display() {
    List<Integer> layerKeys = new ArrayList<Integer>(layers.keySet());
    Collections.sort(layerKeys);
    
    for (int layer : layerKeys) {
      for (Face face : layers.get(layer)) {
        face.display();  
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
