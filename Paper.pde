
class Paper {  
  Set<Vertex> dragNodes;
  LinkedList<Layer> layers;
  //LinkedList<LinkedList<Vertex>> layerVerts;
  
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
      //layerVerts = (LinkedList<LinkedList<Vertex>>) deepClone(other.layerVerts);
      layers = (LinkedList<Layer>) deepClone(other.layers);
    }catch (NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
  
  Paper(float size, Texture front, Texture back, color border) {
      this.dragNodes = new HashSet<>();
      this.layers = new LinkedList<>();
      //this.layerVerts = new LinkedList<>();

      this.front = front;
      this.back = back;
      this.border = border;
      createSquare(size);
  }
  
  private void createSquare(float size) {
    LinkedList<Vertex> nodes = new LinkedList<>(Arrays.asList(
        new Vertex(-size/2, -size/2, 0, 0),
        new Vertex( size/2, -size/2, 1, 0),
        new Vertex( size/2,  size/2, 1, 1),
        new Vertex(-size/2,  size/2, 0, 1)));
    
    Layer base = new Layer(
        new HashSet<>(Arrays.asList(
            new Face(nodes.get(0), nodes.get(1), nodes.get(2)),
            new Face(nodes.get(0), nodes.get(2), nodes.get(3)))),
        new LinkedList<>(Arrays.asList(
            new Edge(nodes.get(0), nodes.get(1)),
            new Edge(nodes.get(1), nodes.get(2)),
            new Edge(nodes.get(2), nodes.get(3)),
            new Edge(nodes.get(3), nodes.get(0))))
    );
    //layerVerts.add(firstLayer);
    layers.add(base);
    dragNodes.addAll(nodes);    
  }
  
  private void calcVertices() {
    dragNodes.clear();
    //layerVerts.clear();
    
    for (Layer layer : layers) {
      Set<Vertex> newLayerVerts = new HashSet<>();
      
      for (Face face : layer.faces) {
        newLayerVerts.add(face.v0);
        newLayerVerts.add(face.v1);
        newLayerVerts.add(face.v2);
      }
      LinkedList<Vertex> hull = convexHull(new LinkedList<>(newLayerVerts));
      //layerVerts.addLast(hull);
      dragNodes.addAll(hull);
    }
  }
  
  void flip() {
    Collections.reverse(layers);
    Line mid = new Line(new PVector(0, 0), new PVector(0, 1));
    
    for (Layer layer : layers) {
      layer.flip(mid);  
    }
    calcVertices();
  }
  
  void display(PGraphics g) {
    //Iterator<LinkedList<Vertex>> it = layerVerts.iterator();

    for (Layer layer : layers) {
      layer.display(g, front, back, border);
      //displayHull(it.next(), g);
      //g.noStroke();

      //for (Face face : layer) {
        //face.display(g, front, back);  
      //}
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
    LinkedList<Layer> newLayers = new LinkedList<>();
    Iterator<Layer> it = layers.descendingIterator();
    
    while(it.hasNext()) {
      Layer layer = it.next();
      Pair<Layer, Layer> splitLayer = layer.fold(crease);
      
      if (null != splitLayer.first) {
        newLayers.addFirst(splitLayer.first);  
      }
      if (null != splitLayer.second) {
        newLayers.addLast(splitLayer.second);
      }
      
      //Set<Face> newBotLayer = new HashSet<>();
      //Set<Face> newTopLayer = new HashSet<>();
      
      //for (Face face : layer) {
      //  Set<Face> subdivisions = face.subdivide(crease);
        
      //  for (Face newFace : subdivisions) {
      //    if (crease.liesToRight(newFace.getMid())) {
      //      newFace.flip(crease);
      //      newTopLayer.add(newFace);
      //    }else {
      //      newBotLayer.add(newFace);
      //    }
      //  }
      //}
      //if (!newBotLayer.isEmpty()) {
      //  newLayers.addFirst(newBotLayer);  
      //}
      //if (!newTopLayer.isEmpty()) {
      //  newLayers.addLast(newTopLayer);
      //}
    }
    this.layers = newLayers;
    calcVertices();
  }
  
  @Override
  public Paper clone() {
    return new Paper(this);
  }
}
