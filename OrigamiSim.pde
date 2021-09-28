import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.LinkedList;
import java.util.ListIterator;
import java.util.Iterator;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Collection;
import java.util.Comparator;


Paper paper;
Paper foldedPaper;

PImage img;
PShader edges;
PGraphics canvas;

void setup() {
  size(1200, 800, P2D);
  smooth(8);
  img = loadImage("flow.jpg");
  Texture front = new SolidFill(color(234, 225, 214));
  Texture back = new Graphic(img);

  paper = new Paper(600, front, back, color(55, 82, 145));
  foldedPaper = paper.clone();
  canvas = createGraphics(width, height, P2D);
}

float hoverRad = 20;

void draw() {
  background(255);
  
  canvas.beginDraw();
  canvas.clear();
  canvas.textureMode(NORMAL);
  canvas.strokeWeight(7);
  canvas.strokeJoin(ROUND);

  //canvas.background(255);
  canvas.translate(width/2f, height/2f);
  
  if (null != draggedVertex) {
    boolean didMove = transitionFoldMovement();
    
    if (didMove) {
      foldNewPaper(draggedVertex);
    }
  }
  foldedPaper.display(canvas);
  canvas.endDraw();
  image(canvas, 0, 0);
  
  if (!mousePressed) {
    translate(width/2f, height/2f);
    encircle(getHoveredVertex(paper, hoverRad), hoverRad, color(255, 0, 0, 32));
  }
}

float transitionSpeed = 1/4f;

boolean transitionFoldMovement() {
  PVector mousePos = new PVector(mouseX, mouseY);
  
  if (dragTarget.dist(mousePos) < 0.1) {
    dragTarget.set(mousePos);
    return false;
  }
  dragTarget.add(mousePos.sub(dragTarget).mult(transitionSpeed));
  return true;
}

void foldNewPaper(Vertex draggedVertex) {
  PVector newPos = dragTarget.copy().add(dragOffset);
  PVector lineMid = newPos.copy().add(draggedVertex.pos).mult(0.5);
  PVector lineDir = newPos.copy().sub(draggedVertex.pos).normalize().cross(new PVector(0, 0, 1));
  
  Line crease = new Line(lineMid, lineDir);
  foldedPaper = paper.clone();
  foldedPaper.fold(draggedVertex, crease); 
}

void keyPressed() {
  switch(key) {
    case 'f':
      paper.flip();
      break;
  }
}

PVector dragOffset;
Vertex draggedVertex;
PVector dragTarget;

void mousePressed() {
  Vertex vertex = getHoveredVertex(paper, hoverRad);
  
  if (null == vertex) {
    return;  
  }
  dragOffset = vertex.getPos().sub(mouseX, mouseY);
  dragTarget = new PVector(mouseX, mouseY);
  draggedVertex = vertex;  
  foldedPaper = paper.clone();
}

void mouseReleased() {
  if (null == draggedVertex) {
    return;
  }
  if (foldedPaper.layers.size() <= 64) {
    paper = foldedPaper;
  }else {
    println("the paper is too thick to fold");  
  }
  draggedVertex = null;
}

Vertex getHoveredVertex(Paper paper, float radius) {
  PVector cursor = new PVector(mouseX - width/2f, mouseY - height/2f);
  Vertex closest = null;
  float minDist = radius;
  
  for (Vertex vertex : paper.dragNodes.keySet()) {
    float dist = cursor.dist(vertex.pos);
    
    if (dist < minDist) {
      closest = vertex;
      minDist = dist;
    }
  }
  return closest;
}

void encircle(Vertex v, float radius, color c) {
  if (null == v) {
    return;
  }
  fill(c);
  noStroke();
  ellipse(v.pos.x, v.pos.y, 2*radius, 2*radius);
}

static Object deepClone(Object obj) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  if (obj instanceof List) {
    return deepCloneList((List) obj);
  } else if (obj instanceof Map) {
    return deepCloneMap((Map) obj);
  } else if (obj instanceof Set) {
    return deepCloneSet((Set) obj);
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

static <T> LinkedList<T> deepCloneList(List<T> list) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  LinkedList<T> listCopy = new LinkedList<T>();
  for (T obj : list) {
    T objCopy = (T) deepClone(obj);
    listCopy.addLast(objCopy);
  }
  return listCopy;
}

static <T> HashSet<T> deepCloneSet(Set<T> set) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  HashSet<T> setCopy = new HashSet<T>();
  for (T obj : set) {
    T objCopy = (T) deepClone(obj);
    setCopy.add(objCopy);
  }
  return setCopy;
}

static <T> ArrayList<T> deepCopy(List<T> list) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException{
  ArrayList<T> listCopy = new ArrayList<T>();
  for (T obj : list) {
    T objCopy = (T) obj.getClass().getMethod("copy").invoke(obj);
    listCopy.add(objCopy);
  }
  return listCopy;
}

/**
 * Returns true if the second direction vector points to the right compared to the first one. (in 2D processing  space)
 */
boolean turnsToRight(PVector dir0, PVector dir1) {
  float dot = dir0.x * dir1.y - dir0.y * dir1.x;
  return dot <= 0;
}
