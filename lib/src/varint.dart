import 'dart:typed_data';

import 'exception.dart';

/// Covert int value to varint encoded [Uint8List] value.
///
/// If value is negative, throw [EncodeVarintException].
Uint8List varintEncoder(int value) {
  if (value < 0) throw EncodeVarintException('value can not be negative');

  var buf = BytesBuilder(copy: false);
  while (value >= 0x80) {
    buf.addByte((value & 0x7f) | 0x80);
    value >>= 7;
  }
  buf.addByte(value);
  return buf.takeBytes();
}

/// Covert varint-encoded [Uint8List] value to int value.
///
/// If value is empty, throw [DecodeVarintException].
/// If value is overflow, throw [DecodeVarintException].
/// The first value of the returned record is the decoded int value.
/// The second value of the returned record is the length of the encoded varint.
(int, int) varintDecoder(Uint8List value) {
  if (value.isEmpty) {
    throw DecodeVarintException('value can not be an empty list');
  }
  var result = 0;
  var shift = 0;
  for (var i = 0; i < value.length; i++) {
    var byte = value[i];
    if (byte < 0x80) {
      if (i > 9 || i == 9 && byte > 1) {
        throw DecodeVarintException('varint overflow');
      }
      return (result | (byte << shift), i + 1);
    }
    result |= (byte & 0x7f) << shift;
    shift += 7;
  }
  throw DecodeVarintException('varint overflow');
}
