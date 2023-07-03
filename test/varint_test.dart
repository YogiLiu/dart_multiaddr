import 'dart:typed_data';

import 'package:dart_multiaddr/src/exception.dart';
import 'package:dart_multiaddr/src/varint.dart';
import 'package:test/test.dart';

void main() {
  var testGroups = [
    // encode group
    (
      'encode',
      [
        (
          '-1',
          () => varintEncoder(-1),
          null,
          TypeMatcher<EncodeVarintException>()
        ),
        ('0', () => varintEncoder(0), [0], null),
        ('1', () => varintEncoder(1), [1], null),
        ('126', () => varintEncoder(126), [126], null),
        ('127', () => varintEncoder(127), [127], null),
        ('128', () => varintEncoder(128), [128, 1], null),
        ('254', () => varintEncoder(254), [254, 1], null),
        ('255', () => varintEncoder(255), [255, 1], null),
        ('256', () => varintEncoder(256), [128, 2], null),
      ]
    ),
    // decode group
    (
      'decode',
      [
        (
          'empty',
          () => varintDecoder(Uint8List.fromList([])),
          null,
          TypeMatcher<DecodeVarintException>()
        ),
        ('0', () => varintDecoder(Uint8List.fromList([0])), (0, 1), null),
        (
          '0 and rest',
          () => varintDecoder(Uint8List.fromList([0, 1])),
          (0, 1),
          null
        ),
        ('1', () => varintDecoder(Uint8List.fromList([1])), (1, 1), null),
        ('126', () => varintDecoder(Uint8List.fromList([126])), (126, 1), null),
        ('127', () => varintDecoder(Uint8List.fromList([127])), (127, 1), null),
        (
          'overflow',
          () => varintDecoder(Uint8List.fromList([128])),
          null,
          TypeMatcher<DecodeVarintException>()
        ),
        (
          '128',
          () => varintDecoder(Uint8List.fromList([128, 1])),
          (128, 2),
          null
        ),
        (
          '128 and rest',
          () => varintDecoder(Uint8List.fromList([128, 1, 1])),
          (128, 2),
          null
        ),
        (
          '255',
          () => varintDecoder(Uint8List.fromList([255, 1])),
          (255, 2),
          null
        ),
        (
          '256',
          () => varintDecoder(Uint8List.fromList([128, 2])),
          (256, 2),
          null
        ),
        (
          'twice overflow',
          () => varintDecoder(Uint8List.fromList([128, 128])),
          null,
          TypeMatcher<DecodeVarintException>()
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
