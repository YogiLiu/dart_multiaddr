import 'dart:typed_data';

import 'package:dart_multiaddr/src/exception.dart';
import 'package:dart_multiaddr/src/protocol.dart';
import 'package:test/test.dart';

void main() {
  var testGroups = [
    // from name
    (
      'from name',
      [
        ('ip4', () => Protocol.fromName('ip4'), Protocol.ip4, null),
        (
          'error name',
          () => Protocol.fromName('error name'),
          null,
          TypeMatcher<ProtocolException>()
        ),
      ]
    ),
    // from code
    (
      'from code',
      [
        ('0x04', () => Protocol.fromCode(0x04), Protocol.ip4, null),
        (
          'error name',
          () => Protocol.fromCode(0x99999999999999),
          null,
          TypeMatcher<ProtocolException>()
        ),
      ]
    ),
    // from vcode
    (
      'from vcode',
      [
        (
          '4',
          () => Protocol.fromVcode(Uint8List.fromList([4])),
          Protocol.ip4,
          null
        ),
        (
          '0',
          () => Protocol.fromVcode(Uint8List.fromList([0])),
          null,
          TypeMatcher<ProtocolException>()
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
