
class Layer {
  
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

  void addFace(Face face) {
    faces.add(face);  
  }

  void addEdge(Edge edge) {
    edges.add(edge);  
  }
  
  void mirror(Line crease) {
      
  }
  
  Pair<Layer, Layer> fold(Line crease) {
    Pair<List<Edge>, List<Edge>> newLayerBounds = calcNewPolygons(crease);
    
    if (null == newLayerBounds) {
      if (crease.liesToRight(edges.get(0).start.pos)) {
        this.mirror(crease);  
      }
      return null;
    }
    Pair<Set<Face>, Set<Face>> newLayerFaces = divideFaces(crease);
    Layer layerLeft = new Layer();
    Layer layerRight = new Layer();    

    layerLeft.addAllEdges(newLayerBounds.first);
    layerRight.addAllEdges(newLayerBounds.second);
    return new Pair<>(layerLeft, layerRight);
  }
  
  Pair<Set<Face>, Set<Face>> divideFaces(Line crease) {
    
    for (Face face : faces) {
      Set<Face> subdivisions = face.subdivide(crease);
      
      for (Face newFace : subdivisions) {
        if (crease.liesToRight(newFace.getMid())) {
          //newFace.flip(crease);
          layerLeft.addFace(newFace);
        }else {
          layerRight.addFace(newFace);
        }
      }
    }
    return null;
  }
  
  Pair<List<Edge>, List<Edge>> calcNewPolygons(Line crease) {
    Vertex in = null;
    Vertex out = null;
    int inIndex = -1;
    int outIndex = -1;
    
    for (int i = 0; i < edges.size(); ++i) {
      Edge edge = edges.get(i);
      Vertex inters = edge.intersect(crease);
      
      if (null == inters) {
        continue;  
      }
      if (crease.liesToRight(edge.start.pos)) {
        in = inters;
        inIndex = i;
      } else {
        out = inters;  
        outIndex = i;
      }
    }
    if (null == in) {
      return null;
    }
    return new Pair<>(
        createSubPolygon(inIndex, outIndex, in, out),
        createSubPolygon(outIndex, inIndex, out, in));
  }
  
  List<Edge> createSubPolygon(int startIndex, int endIndex, Vertex first, Vertex last) {
    List<Edge> polygon = new ArrayList<>();
    polygon.add(new Edge(first, edges.get(startIndex).end));
    
    int edgeCount = edges.size();
    int distance = (endIndex + edgeCount - startIndex) % edgeCount;
    
    for (int i = startIndex+1; i < startIndex + distance; ++i) {
      polygon.add(edges.get(i % edgeCount).clone());  
    }
    polygon.add(new Edge(edges.get(endIndex).start, last));
    polygon.add(new Edge(last, first));
    return polygon;
  }
  
  //Edge calcTotalCrease(Set<Edge> subEdges) {
  //  Vertex start = null;
  //  Vertex end = null;
  //  float edgeLength = 0;
    
  //  for (Edge edge : subEdges) {
  //    if (null == start) {
  //      start = edge.start;
  //      end = edge.end;
  //      edgeLength = edge.length();
  //      continue;
  //    }
  //    float distStart = end.pos.dist(edge.start.pos);

  //    if (distStart > edgeLength) {
  //      start = edge.start; 
  //      edgeLength = distStart;
  //      continue;
  //    }
  //    float distEnd = start.pos.dist(edge.end.pos);
      
  //    if (distEnd > edgeLength) {
  //      end = edge.end;
  //      edgeLength = distEnd;
  //    }
  //  }
  //  return new Edge(start, end);
  //}
}
