import java.util.Comparator;

LinkedList<Vertex> convexHull(LinkedList<Vertex> vertices) {
  LinkedList<Vertex> hull = new LinkedList<>();
  Collections.sort(vertices, new YxComparator());
  
  Vertex start = vertices.getFirst();
  hull.addFirst(start);
  vertices.removeFirst();
  Collections.sort(vertices, new AngleComparator(start));
  
  hull.addFirst(vertices.getFirst());
  vertices.removeFirst();
  hull.addFirst(vertices.getFirst());
  vertices.removeFirst();
  
  while (!vertices.isEmpty()) {
    while (hull.size() > 1 && turnsToLeft(hull.get(1), hull.getFirst(), vertices.getFirst())) {
      hull.removeFirst();
    }
    hull.addFirst(vertices.getFirst());
    vertices.removeFirst();
  }
  return hull;
}

class YxComparator implements Comparator<Vertex> {
  public int compare(Vertex a, Vertex b) {
    int compY = Float.compare(a.pos.y, b.pos.y);
    return compY != 0 ? compY : Float.compare(a.pos.x, b.pos.x);
  }
}

class AngleComparator implements Comparator<Vertex> {
  Vertex start;
  
  AngleComparator(Vertex start) {
    this.start = start;  
  }
  
  public int compare(Vertex a, Vertex b) {
    return Float.compare(polarAngle(start.pos, a.pos), polarAngle(start.pos, b.pos));
  }
}

float polarAngle(PVector a, PVector b) {
  return atan2(b.x - a.x, b.y - a.y);
}

boolean turnsToLeft(Vertex pivot, Vertex a, Vertex b) {
  float dirX0 = a.pos.x - pivot.pos.x;
  float dirX1 = b.pos.x - pivot.pos.x;
  float dirY0 = a.pos.y - pivot.pos.y;
  float dirY1 = b.pos.y - pivot.pos.y;  
  return dirX0 * dirY1 - dirY0 * dirX1 >= 0;
  //return turnsToRight(a.getPos().sub(pivot.pos), b.getPos().sub(pivot.pos));
}
