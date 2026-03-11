// String getChatId(String id1, String id2) {
//   return id1.compareTo(id2) > 0 ? '$id1-$id2' : '$id2-$id1';
// }
String getChatId(String id1, String id2) {
  return id1.compareTo(id2) > 0 ? '$id1-$id2' : '$id2-$id1';
}