import java.util.Comparator;

LinkedList<Vertex> convexHull(LinkedList<Vertex> vertices) {
  LinkedList<Vertex> hull = new LinkedList<Vertex>();
  println("\nsort", vertices.size(), "verts");
  Collections.sort(vertices, new YxComparator());
  println(vertices, "\n");
  
  Vertex start = vertices.getFirst();
  hull.addFirst(start);
  vertices.removeFirst();
  println("1st", start.pos);
  Collections.sort(vertices, new AngleComparator(start));
  
  hull.addFirst(vertices.getFirst());
  println("2nd", vertices.getFirst().pos);
  vertices.removeFirst();
  hull.addFirst(vertices.getFirst());
  println("3rd", vertices.getFirst().pos);
  vertices.removeFirst();
  
  while (!vertices.isEmpty()) {
    println(hull.size(), "next", vertices.getFirst().pos);
    while (!turnsToRight(hull.get(1), hull.getFirst(), vertices.getFirst())) {
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

boolean turnsToRight(Vertex pivot, Vertex a, Vertex b) {
  return turnsToRight(a.getPos().sub(pivot.pos), b.getPos().sub(pivot.pos));
}
