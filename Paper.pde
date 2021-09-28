
class Paper {  
  LinkedList<Layer> layers;
  Map<Vertex, Layer> dragNodes;
  
  Texture front;
  Texture back;
  color border;
  boolean isFlipped;
  
  Paper(Paper other) {
    this.front = other.front;
    this.back = other.back;
    this.border = other.border;
    
    try {
      layers = (LinkedList<Layer>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
    dragNodes = new HashMap<>();
    calcDragNodes();
  }
  
  Paper(float size, Texture front, Texture back, color border) {
      this.dragNodes = new HashMap<>();
      this.layers = new LinkedList<>();

      this.front = front;
      this.back = back;
      this.border = border;
      createSquare(size);
      calcDragNodes(); 
  }
  
  private void createSquare(float size) {
    LinkedList<Vertex> verts = new LinkedList<>(Arrays.asList(
        new Vertex(-size/2, -size/2, 0, 0),
        new Vertex( size/2, -size/2, 1, 0),
        new Vertex( size/2,  size/2, 1, 1),
        new Vertex(-size/2,  size/2, 0, 1)));
    
    Layer base = new Layer(
        new HashSet<>(Arrays.asList(
            new Face(verts.get(0), verts.get(1), verts.get(2)),
            new Face(verts.get(0), verts.get(2), verts.get(3)))),
        new LinkedList<>(Arrays.asList(
            new Edge(verts.get(0), verts.get(1)),
            new Edge(verts.get(1), verts.get(2)),
            new Edge(verts.get(2), verts.get(3)),
            new Edge(verts.get(3), verts.get(0))))
    );
    layers.add(base);
  }
  
  private void calcDragNodes() {
    dragNodes.clear();
    
    for (Layer layer : layers) {
      for (Edge edge : layer.edges) {
        dragNodes.putIfAbsent(edge.start, layer);  
      }
    }
  }
  
  Paper flip() {
    Collections.reverse(layers);
    Line mid = new Line(new PVector(0, 0), new PVector(0, 1));
    
    for (Layer layer : layers) {
      layer.flip(mid);  
    }
    calcDragNodes();
    return this;
  }
  
  void display(PGraphics g) {
    for (Layer layer : layers) {
      layer.display(g, front, back, border);
    }
  }
  
  void fold(Vertex draggedVertex, Line crease) {
    LinkedList<Layer> newLayers = new LinkedList<>();
    
    Layer startLayer = dragNodes.get(draggedVertex);
    int startIndex = layers.indexOf(startLayer);
    startLayer.adjustCrease(crease);
    
    for (int i = layers.size()-1; i >= startIndex; --i) {
      Layer layer = layers.get(i);
      Pair<Layer, Layer> splitLayer = layer.fold(crease);
      
      if (null != splitLayer.first) {
        newLayers.addFirst(splitLayer.first);  
      }
      if (null != splitLayer.second) {
        newLayers.addLast(splitLayer.second);
      }
    }
    ListIterator<Layer> it2 = layers.listIterator(startIndex);
    
    while (it2.hasPrevious()) {
      newLayers.addFirst(it2.previous());  
    }
    
    this.layers = newLayers;
    calcDragNodes();
  }
  
  @Override
  public Paper clone() {
    return new Paper(this);
  }
}
