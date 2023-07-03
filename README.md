# dart_multiaddr

> [multiaddr](https://github.com/multiformats/multiaddr) implementation in Dart

Multiaddr aims to make network addresses future-proof, composable, and efficient.

**Warning**: This is a work in progress. The API is not stable yet.

## Usage

```dart
import 'package:dart_multiaddr/dart_multiaddr.dart';

void main() {
  var addr = Multiaddr.fromString('/ip4/1.1.1.1');
  print(addr.toString());  // Output: /ip4/1.1.1.1

  var anotherAddr = Multiaddr.fromString('/ip4/1.1.1.1');
  print(addr == anotherAddr);  // Output: true
}
```

## License

[MIT](./LICENSE) © 2023 YogiLiu
