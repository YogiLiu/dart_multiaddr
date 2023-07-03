import 'dart:typed_data';

import 'exception.dart';
import 'protocol.dart';
import 'varint.dart';

/// Multiaddr is a format for encoding addresses from various well-established
/// network protocols.
///
/// It is useful to write applications that future-proof their use of addresses,
/// and allow multiple transport protocols and addresses to coexist.
/// Read more: [multiaddr](https://multiformats.io/multiaddr/)
class Multiaddr {
  final List<Component> components;

  Multiaddr(this.components);

  factory Multiaddr.fromString(String addr) {
    if (addr.startsWith('/')) {
      addr = addr.substring(1);
    } else {
      throw MultiaddrException('multiaddr must start with a "/"');
    }
    var parts = addr.split('/');
    var components = <Component>[];
    var pos = 0; // current position in parts.
    while (pos < parts.length) {
      var part = parts[pos];
      pos++;
      Protocol protocol;
      try {
        protocol = Protocol.fromName(part);
      } on ProtocolException {
        throw MultiaddrException('invalid protocol: $part');
      }
      if (protocol.size == 0) {
        // no value.
        components.add(Component(protocol));
        continue;
      }
      if (pos + 1 > parts.length) {
        throw MultiaddrException('protocol $part requires value');
      }
      Uint8List value;
      if (protocol.hasPath) {
        // variable length and has path.
        var path = '/${parts.sublist(pos).join('/')}';
        pos = parts.length;
        value = protocol.encodeValue(path);
      } else {
        // two cases:
        // 1. variable length and has not path
        // 2. fixed length
        value = protocol.encodeValue(parts[pos]);
        pos++;
      }
      components.add(Component(protocol, value));
    }
    return Multiaddr(components);
  }

  factory Multiaddr.fromUint8List(Uint8List addr) {
    if (addr.isEmpty) {
      throw MultiaddrException('addr is empty');
    }
    var pos = 0; // current position in addr.
    var components = <Component>[];
    while (pos < addr.length) {
      var (vcode, len) = varintDecoder(addr.sublist(pos));
      pos += len;
      Protocol protocol;
      try {
        protocol = Protocol.fromCode(vcode);
      } on ProtocolException catch (e) {
        throw MultiaddrException(e.message);
      }
      switch (protocol.size) {
        case == 0:
          // no value.
          components.add(Component(protocol));
          break;
        case > 0:
          // fixed length.
          var listLen = (protocol.size / 8).ceil();
          if (pos + listLen > addr.length) {
            throw MultiaddrException(
                'protocol ${protocol.name} requires value');
          }
          var value = addr.sublist(pos, pos + listLen);
          pos += listLen;
          components.add(Component(protocol, value));
          break;
        default:
          // variable length.
          var (valSize, len) = varintDecoder(addr.sublist(pos));
          pos += len;
          if (pos + len > addr.length) {
            throw MultiaddrException(
                'protocol ${protocol.name} requires value');
          }
          var valLen = (valSize / 8).ceil();
          var value = addr.sublist(pos, pos + valLen);
          pos += valLen;
          components.add(Component(protocol, value));
      }
    }
    return Multiaddr(components);
  }

  @override
  String toString() {
    var buf = StringBuffer();
    for (var comp in components) {
      buf.write(comp.toString());
    }
    return buf.toString();
  }

  Uint8List toUint8List() {
    var buf = BytesBuilder(copy: false);
    for (var comp in components) {
      buf.add(comp.toUint8List());
    }
    return buf.takeBytes();
  }

  bool _compareComponents(Multiaddr addr) {
    if (components.length != addr.components.length) {
      return false;
    }
    for (var i = 0; i < components.length; i++) {
      if (components[i] != addr.components[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Multiaddr &&
          runtimeType == other.runtimeType &&
          components.length == other.components.length &&
          _compareComponents(other);

  @override
  int get hashCode {
    var code = 0;
    for (var comp in components) {
      code ^= comp.hashCode;
    }
    return code;
  }
}

/// A [Multiaddr] component.
class Component {
  final Protocol protocol;
  final Uint8List? value;

  Component(this.protocol, [this.value]);

  @override
  String toString() {
    if (protocol.size == 0) {
      return '/${protocol.name}';
    } else {
      // variable length and fixed length.
      var buf = StringBuffer();
      buf.write('/');
      buf.write(protocol.name);
      if (!protocol.hasPath) {
        buf.write('/');
      }
      var val = protocol.decodeValue(value!);
      buf.write(val);
      return buf.toString();
    }
  }

  Uint8List toUint8List() {
    if (protocol.size == 0) {
      return protocol.vcode;
    } else if (protocol.size > 0) {
      //fixed length
      var buf = BytesBuilder(copy: false);
      buf.add(protocol.vcode);
      buf.add(value!);
      return buf.takeBytes();
    } else {
      // variable length.
      var buf = BytesBuilder(copy: false);
      buf.add(protocol.vcode);
      // Every element in Uint8list is 8 bits,
      // so the length of n-length Uint8list is 8n bits.
      buf.add(varintEncoder(value!.length * 8));
      buf.add(value!);
      return buf.takeBytes();
    }
  }

  bool _compareValue(Component comp) {
    if (value == comp.value) {
      return true;
    } else if (value == null || comp.value == null) {
      return false;
    } else if (value!.length != comp.value!.length) {
      return false;
    } else {
      for (var i = 0; i < value!.length; i++) {
        if (value![i] != comp.value![i]) {
          return false;
        }
      }
      return true;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Component &&
          runtimeType == other.runtimeType &&
          protocol == other.protocol &&
          _compareValue(other);

  @override
  int get hashCode {
    var code = 0;
    if (value != null) {
      for (var v in value!) {
        code ^= v;
      }
    }
    return protocol.hashCode ^ code;
  }
}
