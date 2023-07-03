import 'package:dart_multiaddr/dart_multiaddr.dart';

void main() {
  var addr = Multiaddr.fromString('/ip4/1.1.1.1');
  print(addr.toString());  // Output: /ip4/1.1.1.1

  var anotherAddr = Multiaddr.fromString('/ip4/1.1.1.1');
  print(addr == anotherAddr);  // Output: true
}