
class Pair<K, V> {
  K first;
  V second;
  
  Pair(K first, V second) {
    this.first = first;
    this.second = second;
  }
  
  K first() {
    return first;  
  }
  
  V second() {
    return second();  
  }
}
