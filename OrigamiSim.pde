import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;

Paper paper;

void setup() {
  size(1200, 800);  
  paper = new Paper(400);  
}

float hoverRad = 20;

void draw() {
  background(255);
  translate(width/2f, height/2f);
  
  if (mousePressed && null != draggedVertex) {
    PVector currentPos = dragOffset.copy().add(mouseX, mouseY);
    displayCrease(draggedVertex, currentPos);
    ellipse(currentPos.x, currentPos.y, 10, 10);
  }else {
    paper.display();
    encircle(getHoveredVertex(paper, hoverRad), hoverRad, color(255, 0, 0, 32));
  }
}

void displayCrease(PVector vertex, PVector newPos) {
  PVector lineMid = vertex.copy().add(newPos).mult(0.5);
  PVector lineDir = vertex.copy().sub(newPos).normalize().cross(new PVector(0, 0, 1));
  
  Line crease = new Line(lineMid, lineDir);
  Paper foldedPaper = paper.clone();
  foldedPaper.fold(crease, vertex);
  foldedPaper.display();
  
  List<PVector> foldPoints = new ArrayList<PVector>();
  for (LineSegment edge : paper.edges) {
    PVector intersection = edge.intersect(crease);
     
    if (null != intersection) {
      foldPoints.add(intersection);
    }
  }
  if (foldPoints.size() == 2 ) {
    stroke(0, 0, 255);
    line(foldPoints.get(0).x, 
      foldPoints.get(0).y,
      foldPoints.get(1).x, 
      foldPoints.get(1).y);
  }
}

PVector dragOffset;
PVector draggedVertex;

void mousePressed() {
  PVector vertex = getHoveredVertex(paper, hoverRad);
  
  if (null == vertex) {
    return;  
  }
  dragOffset = vertex.copy().sub(mouseX, mouseY);
  draggedVertex = vertex;  
}

void mouseReleased() {
  draggedVertex = null;
}

PVector getHoveredVertex(Paper paper, float radius) {
  PVector cursor = new PVector(mouseX - width/2f, mouseY - height/2f);

  for (PVector vertex : paper.vertices) {
    float dist = cursor.dist(vertex);
    
    if (dist <= radius) {
      return vertex;
    }
  }
  return null;
}

void encircle(PVector p, float radius, color c) {
  if (null == p) {
    return;
  }
  fill(c);
  noStroke();
  ellipse(p.x, p.y, 2*radius, 2*radius);
}

static <T> ArrayList<T> deepClone(List<T> list) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  ArrayList<T> listCopy = new ArrayList<T>();
  for (T obj : list) {
    T objCopy = (T) obj.getClass().getMethod("clone").invoke(obj);
    listCopy.add(objCopy);
  }
  return listCopy;
}

static <T> ArrayList<T> deepCopy(List<T> list) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  ArrayList<T> listCopy = new ArrayList<T>();
  for (T obj : list) {
    T objCopy = (T) obj.getClass().getMethod("copy").invoke(obj);
    listCopy.add(objCopy);
  }
  return listCopy;
}

boolean turnsToRight(PVector v0, PVector v1) {
  float dot = v0.x * v1.y - v0.y * v1.x;
  return dot <= 0;
}
