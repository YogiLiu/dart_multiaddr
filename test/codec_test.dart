import 'dart:typed_data';

import 'package:dart_multiaddr/src/codec.dart';
import 'package:dart_multiaddr/src/exception.dart';
import 'package:test/test.dart';

void main() {
  var testGroups = [
    // ip4 group
    (
      'ip4',
      [
        ('encode 0.0.0.0', () => ip4Encoder('0.0.0.0'), [0, 0, 0, 0], null),
        (
          'encode 192.168.0.1',
          () => ip4Encoder('192.168.0.1'),
          [192, 168, 0, 1],
          null
        ),
        (
          'encode 255.255.255.255',
          () => ip4Encoder('255.255.255.255'),
          [255, 255, 255, 255],
          null
        ),
        (
          'encode 1.1.1',
          () => ip4Encoder('1.1.1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode 1.1.1.1.1',
          () => ip4Encoder('1.1.1.1.1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode 1.1.1.256',
          () => ip4Encoder('1.1.1.256'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode 1.1.1.a',
          () => ip4Encoder('1.1.1.a'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'decode 0.0.0.0',
          () => ip4Decoder(Uint8List.fromList([0, 0, 0, 0])),
          '0.0.0.0',
          null
        ),
        (
          'decode 192.168.0.1',
          () => ip4Decoder(Uint8List.fromList([192, 168, 0, 1])),
          '192.168.0.1',
          null
        ),
        (
          'decode 255.255.255.255',
          () => ip4Decoder(Uint8List.fromList([255, 255, 255, 255])),
          '255.255.255.255',
          null
        ),
        (
          'decode 1.1.1',
          () => ip4Decoder(Uint8List.fromList([1, 1, 1])),
          null,
          TypeMatcher<DecodeException>()
        ),
        (
          'decode 1.1.1.1.1',
          () => ip4Decoder(Uint8List.fromList([1, 1, 1, 1, 1])),
          null,
          TypeMatcher<DecodeException>()
        ),
      ]
    ),
    // tcp group
    (
      'tcp',
      [
        ('encode 0', () => tcpEncoder('0'), [0, 0], null),
        ('encode 1', () => tcpEncoder('1'), [0, 1], null),
        ('encode 65535', () => tcpEncoder('65535'), [255, 255], null),
        (
          'encode -1',
          () => tcpEncoder('-1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode 65536',
          () => tcpEncoder('65536'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode str',
          () => tcpEncoder('str'),
          null,
          TypeMatcher<EncodeException>()
        ),
        ('decode 0', () => tcpDecoder(Uint8List.fromList([0, 0])), '0', null),
        ('decode 1', () => tcpDecoder(Uint8List.fromList([0, 1])), '1', null),
        (
          'decode 65535',
          () => tcpDecoder(Uint8List.fromList([255, 255])),
          '65535',
          null
        ),
        (
          'decode value too long',
          () => tcpDecoder(Uint8List.fromList([1, 1, 1])),
          null,
          TypeMatcher<DecodeException>()
        ),
        (
          'decode value too short',
          () => tcpDecoder(Uint8List.fromList([1])),
          null,
          TypeMatcher<DecodeException>()
        ),
        (
          'decode empty',
          () => tcpDecoder(Uint8List.fromList([1])),
          null,
          TypeMatcher<DecodeException>()
        ),
      ]
    ),
    // ip6 group
    (
      'ip6',
      [
        (
          'encode empty',
          () => ip6Encoder(''),
          null,
          TypeMatcher<EncodeException>()
        ),
        ('encode ::', () => ip6Encoder('::'), Uint8List(16), null),
        (
          'encode :::',
          () => ip6Encoder(':::'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode ::1',
          () => ip6Encoder('::1'),
          [for (var _ = 0; _ < 15; _++) 0, 1],
          null
        ),
        (
          'encode 1:1fF::1',
          () => ip6Encoder('1:1fF::1'),
          [0, 1, 1, 255, for (var _ = 0; _ < 11; _++) 0, 1],
          null
        ),
        (
          'encode 1::1::1',
          () => ip6Encoder('1::1::1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode too long',
          () => ip6Encoder('1:1:1:1:1:1:1:1:1'),
          null,
          TypeMatcher<EncodeException>()
        ),
        (
          'encode IPv4-mapped IPv6 address',
          () => ip6Encoder('::ffff:135.75.43.52'),
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 135, 75, 43, 52],
          null
        ),
        (
          'decode empty',
          () => ip6Decoder(Uint8List.fromList([])),
          null,
          TypeMatcher<DecodeException>()
        ),
        ('decode ::', () => ip6Decoder(Uint8List(16)), '::', null),
        (
          'decode ::1',
          () => ip6Decoder(
              Uint8List.fromList([for (var _ = 0; _ < 15; _++) 0, 1])),
          '::1',
          null
        ),
        (
          'decode 1:1ff::1',
          () => ip6Decoder(Uint8List.fromList(
              [0, 1, 1, 255, for (var _ = 0; _ < 11; _++) 0, 1])),
          '1:1ff::1',
          null
        ),
        (
          'decode IPv4-mapped IPv6 address',
          () => ip6Decoder(Uint8List.fromList(
              [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 135, 75, 43, 52])),
          '::ffff:135.75.43.52',
          null
        ),
        (
          'decode too long',
          () =>
              ip6Decoder(Uint8List.fromList([for (var _ = 0; _ < 17; _++) 1])),
          null,
          TypeMatcher<DecodeException>()
        ),
      ]
    ),
    // dns group
    (
      'dns',
      [
        (
          'encode github.com',
          () => dnsEncoder('github.com'),
          [103, 105, 116, 104, 117, 98, 46, 99, 111, 109],
          null
        ),
        (
          'decode github.com',
          () => dnsDecoder(Uint8List.fromList(
              [103, 105, 116, 104, 117, 98, 46, 99, 111, 109])),
          'github.com',
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
