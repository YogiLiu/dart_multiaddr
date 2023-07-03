import 'dart:typed_data';

import 'package:dart_multiaddr/src/exception.dart';
import 'package:dart_multiaddr/src/multiaddr.dart';
import 'package:dart_multiaddr/src/protocol.dart';
import 'package:test/test.dart';

void main() {
  var testGroups = [
    // fromString group
    (
      'fromString',
      [
        (
          'equal',
          () => Multiaddr.fromString('/ip4/1.1.1.1'),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1]))
          ]),
          null
        ),
        (
          'not equal',
          () =>
              Multiaddr.fromString('/ip4/1.1.1.1') ==
              Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 2]))
              ]),
          false,
          null
        ),
        (
          'empty',
          () => Multiaddr.fromString(''),
          null,
          TypeMatcher<MultiaddrException>()
        ),
        (
          '/',
          () => Multiaddr.fromString('/'),
          null,
          TypeMatcher<MultiaddrException>()
        ),
        (
          'empty value',
          () => Multiaddr.fromString('/ip4'),
          null,
          TypeMatcher<MultiaddrException>()
        ),
        (
          'error value',
          () => Multiaddr.fromString('/ip4/1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'two protocols',
          () => Multiaddr.fromString('/ip4/1.1.1.1/tcp/3306'),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
            Component(
                Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
          ]),
          null
        ),
        (
          'three protocols (with path)',
          () => Multiaddr.fromString('/ip4/1.1.1.1/tcp/3306/unix/a/b/c'),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
            Component(
                Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
            Component(Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits)),
          ]),
          null
        ),
        (
          'path protocol',
          () => Multiaddr.fromString('/unix/a/b/c'),
          Multiaddr([
            Component(Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits)),
          ]),
          null
        ),
        (
          'path protocol (root)',
          () => Multiaddr.fromString('/unix/'),
          Multiaddr([
            Component(Protocol.unix, Uint8List.fromList('/'.codeUnits)),
          ]),
          null
        ),
        (
          'variable length value',
          () => Multiaddr.fromString('/dns/github.com'),
          Multiaddr([
            Component(Protocol.dns, Uint8List.fromList('github.com'.codeUnits)),
          ]),
          null
        ),
      ]
    ),
    // fromUint8List group
    (
      'fromUint8List',
      [
        (
          'empty',
          () => Multiaddr.fromUint8List(Uint8List(0)),
          null,
          TypeMatcher<MultiaddrException>()
        ),
        (
          'invalid value',
          () => Multiaddr.fromUint8List(Uint8List(100)),
          null,
          TypeMatcher<MultiaddrException>()
        ),
        (
          'equal',
          () => Multiaddr.fromUint8List(Uint8List.fromList([4, 1, 1, 1, 1])),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1]))
          ]),
          null
        ),
        (
          'two protocol',
          () => Multiaddr.fromUint8List(
              Uint8List.fromList([4, 1, 1, 1, 1, 6, 12, 234])),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
            Component(
                Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
          ]),
          null
        ),
        (
          'three protocol (with path)',
          () => Multiaddr.fromUint8List(Uint8List.fromList(
              [4, 1, 1, 1, 1, 6, 12, 234, 144, 3, 48, 47, 97, 47, 98, 47, 99])),
          Multiaddr([
            Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
            Component(
                Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
            Component(Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits)),
          ]),
          null
        ),
        (
          'path protocol',
          () => Multiaddr.fromUint8List(
              Uint8List.fromList([144, 3, 48, 47, 97, 47, 98, 47, 99])),
          Multiaddr([
            Component(Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits))
          ]),
          null
        ),
        (
          'path protocol (root)',
          () => Multiaddr.fromUint8List(Uint8List.fromList([144, 3, 8, 47])),
          Multiaddr(
              [Component(Protocol.unix, Uint8List.fromList('/'.codeUnits))]),
          null
        ),
        (
          'variable length value',
          () => Multiaddr.fromUint8List(Uint8List.fromList(
              [53, 80, 103, 105, 116, 104, 117, 98, 46, 99, 111, 109])),
          Multiaddr([
            Component(Protocol.dns, Uint8List.fromList('github.com'.codeUnits)),
          ]),
          null
        ),
      ]
    ),
    // toString group
    (
      'toString',
      [
        (
          'ip4',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1]))
              ]).toString(),
          '/ip4/1.1.1.1',
          null
        ),
        (
          'dns',
          () => Multiaddr([
                Component(
                    Protocol.dns, Uint8List.fromList('github.com'.codeUnits)),
              ]).toString(),
          '/dns/github.com',
          null
        ),
        (
          'two protocol',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
                Component(
                    Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
              ]).toString(),
          '/ip4/1.1.1.1/tcp/3306',
          null
        ),
        (
          'three protocol (with path)',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
                Component(
                    Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
                Component(
                    Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits)),
              ]).toString(),
          '/ip4/1.1.1.1/tcp/3306/unix/a/b/c',
          null
        ),
        (
          'path protocol (root)',
          () => Multiaddr([
                Component(Protocol.unix, Uint8List.fromList('/'.codeUnits)),
              ]).toString(),
          '/unix/',
          null
        ),
      ]
    ),
    // toUint8List group
    (
      'toUint8List',
      [
        (
          'ip4',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1]))
              ]).toUint8List(),
          [4, 1, 1, 1, 1],
          null
        ),
        (
          'dns',
          () => Multiaddr([
                Component(
                    Protocol.dns, Uint8List.fromList('github.com'.codeUnits)),
              ]).toUint8List(),
          [53, 80, 103, 105, 116, 104, 117, 98, 46, 99, 111, 109],
          null
        ),
        (
          'two protocol',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
                Component(
                    Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
              ]).toUint8List(),
          [4, 1, 1, 1, 1, 6, 12, 234],
          null
        ),
        (
          'three protocol (with path)',
          () => Multiaddr([
                Component(Protocol.ip4, Uint8List.fromList([1, 1, 1, 1])),
                Component(
                    Protocol.tcp, Uint8List.fromList([3306 >> 8, 3306 & 0xff])),
                Component(
                    Protocol.unix, Uint8List.fromList('/a/b/c'.codeUnits)),
              ]).toUint8List(),
          [4, 1, 1, 1, 1, 6, 12, 234, 144, 3, 48, 47, 97, 47, 98, 47, 99],
          null
        ),
        (
          'path protocol (root)',
          () => Multiaddr([
                Component(Protocol.unix, Uint8List.fromList('/'.codeUnits)),
              ]).toUint8List(),
          [144, 3, 8, 47],
          null
        ),
      ]
    )
  ];
  for (var testGroup in testGroups) {
    group(testGroup.$1, () {
      for (var testCase in testGroup.$2) {
        test(testCase.$1, () {
          if (testCase.$4 == null) {
            expect(testCase.$2(), testCase.$3);
          } else {
            expect(testCase.$2, throwsA(testCase.$4));
          }
        });
      }
    });
  }
}
