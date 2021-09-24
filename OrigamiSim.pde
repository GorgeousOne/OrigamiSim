import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;
import java.util.Collections;

Paper paper;
Paper foldedPaper;

PImage img;
PShader edges;
PGraphics canvas;

PShader blur;
PShader shadow;

void setup() {
  size(1200, 800, P2D);
  smooth(8);

  img = loadImage("flow.jpg");
  Texture back = new Graphic(img);
  Texture front = new SolidFill(color(234, 225, 214));
  paper = new Paper(600, front, back, color(55, 82, 145));
  canvas = createGraphics(width, height, P2D);
  
  blur = loadShader("blur.glsl");
  blur.set("blurSize", 9);
  blur.set("sigma", 5.0f);
  
  shadow = loadShader("shadow.glsl");
}

float hoverRad = 20;

void draw() {
  background(255);
  
  canvas.beginDraw();
  canvas.clear();
  canvas.textureMode(NORMAL);
  canvas.translate(width/2f, height/2f);
  
  canvas.strokeWeight(10);
  canvas.strokeJoin(ROUND);
  
  if (null != draggedVertex) {
    boolean didMove = transitionDragMovement();
    
    if (didMove) {
      foldNewPaper();
    }
    foldedPaper.display(canvas);
  }else {
    paper.display(canvas);
  }
  canvas.endDraw();
  image(canvas, 0, 0);
  
  translate(width/2f, height/2f);
  encircle(getHoveredVertex(paper, hoverRad), hoverRad, color(255, 0, 0, 32));
}

float transitionSpeed = 1/4f;

boolean transitionDragMovement() {
  PVector mousePos = new PVector(mouseX, mouseY);
  
  if (dragTarget.dist(mousePos) < 0.1) {
    return false;
  }
  //println(mousePos.sub(dragTarget).mag());
  dragTarget.add(mousePos.sub(dragTarget).mult(transitionSpeed));
  return true;
}

void foldNewPaper() {
  PVector newPos = dragTarget.copy().add(dragOffset);
  PVector lineMid = newPos.copy().add(draggedVertex).mult(0.5);
  PVector lineDir = newPos.copy().sub(draggedVertex).normalize().cross(new PVector(0, 0, 1));
  
  Line crease = new Line(lineMid, lineDir);
  foldedPaper = paper.clone();
  foldedPaper.fold(crease); 
}

PVector dragOffset;
PVector draggedVertex;
PVector dragTarget;

//void mouseDragged() {
//  if (draggedVertex == null) {
//    return;  
//  }
//}

void mousePressed() {
  PVector vertex = getHoveredVertex(paper, hoverRad);
  
  if (null == vertex) {
    return;  
  }
  dragOffset = vertex.copy().sub(mouseX, mouseY);
  dragTarget = new PVector(mouseX, mouseY);
  draggedVertex = vertex;  
  foldedPaper = paper.clone();
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

  for (Vertex vertex : paper.vertices) {
    float dist = cursor.dist(vertex.pos);
    
    if (dist <= radius) {
      return vertex.getPos();
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

boolean turnsToRight(PVector v0, PVector v1) {
  float dot = v0.x * v1.y - v0.y * v1.x;
  return dot <= 0;
}
