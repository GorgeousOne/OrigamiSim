import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;
import java.util.Collections;

Paper paper;
Paper foldedPaper;

void setup() {
  //size(1200, 800);  
  size(1200, 800, P2D);
  smooth(8);
  paper = new Paper(600);  
}

float hoverRad = 20;

void draw() {
  background(255);
  translate(width/2f, height/2f);
  
  if (mousePressed && null != draggedVertex) {
    PVector currentPos = dragOffset.copy().add(mouseX, mouseY);
    displayCrease(draggedVertex, currentPos);
  }else {
    paper.display();
    encircle(getHoveredVertex(paper, hoverRad), hoverRad, color(255, 0, 0, 32));
  }
}

void displayCrease(PVector vertex, PVector newPos) {
  if (vertex.dist(newPos) < 10) {
    paper.display();
    return;
  }
  PVector lineMid = newPos.copy().add(vertex).mult(0.5);
  PVector lineDir = newPos.copy().sub(vertex).normalize().cross(new PVector(0, 0, 1));
  
  Line crease = new Line(lineMid, lineDir);
  foldedPaper = paper.clone();
  foldedPaper.fold(crease);
  foldedPaper.display();
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
  if (null == draggedVertex) {
    return;
  }
  paper = foldedPaper;
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

static Object deepClone(Object obj) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  if (obj instanceof List) {
    return deepCloneList((List) obj);
  } else if (obj instanceof Map) {
    return deepCloneMap((Map) obj);
  } else if (obj instanceof Cloneable) {
    return obj.getClass().getMethod("clone").invoke(obj); 
  }
  return obj;
}

static <K, V> HashMap<K, V> deepCloneMap(Map<K, V> map) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  HashMap<K, V> mapCopy = new HashMap<K, V>();
  
  for (HashMap.Entry<K, V> entry : map.entrySet()) {
    mapCopy.put((K) deepClone(entry.getKey()), (V) deepClone(entry.getValue()));
  }
  return mapCopy;
}

static <T> ArrayList<T> deepCloneList(List<T> list) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  ArrayList<T> listCopy = new ArrayList<T>();
  for (T obj : list) {
    T objCopy = (T) deepClone(obj);
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
