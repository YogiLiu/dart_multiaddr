import 'dart:io';
import 'dart:typed_data';

import 'exception.dart';

/// Encode [value] to bytes.
typedef Encoder = Uint8List Function(String value);

/// Decode [bytes] to String.
typedef Decoder = String Function(Uint8List bytes);

////////////////////////////////////////////////////////////////////////////////
// IP4 Encoder and Decoder
// TODO: support Web
////////////////////////////////////////////////////////////////////////////////
Uint8List ip4Encoder(String value) {
  InternetAddress addr;
  try {
    addr = InternetAddress(value);
  } catch (_) {
    throw EncodeException('invalid ip4 value: $value');
  }
  return addr.rawAddress;
}

String ip4Decoder(Uint8List value) {
  InternetAddress addr;
  try {
    addr = InternetAddress.fromRawAddress(value);
  } catch (_) {
    throw DecodeException('invalid ip4 value: $value');
  }
  return addr.address;
}

////////////////////////////////////////////////////////////////////////////////
// TCP Encoder and Decoder
////////////////////////////////////////////////////////////////////////////////
Uint8List tcpEncoder(String value) {
  var port = int.tryParse(value);
  if (port == null || port < 0 || port > 65535) {
    throw EncodeException('invalid tcp value: $value');
  }
  return Uint8List.fromList([port >> 8, port & 0xff]);
}

String tcpDecoder(Uint8List value) {
  if (value.length != 2) {
    throw DecodeException('invalid tcp value: $value');
  }
  return '${value[0] << 8 | value[1]}';
}

////////////////////////////////////////////////////////////////////////////////
// IP6 Encoder and Decoder
// TODO: support Web
////////////////////////////////////////////////////////////////////////////////
Uint8List ip6Encoder(String value) {
  // TODO: support IPv4-mapped IPv6 addresses
  InternetAddress addr;
  try {
    addr = InternetAddress(value);
  } catch (_) {
    throw EncodeException('invalid ip6 value: $value');
  }
  return addr.rawAddress;
}

String ip6Decoder(Uint8List value) {
  InternetAddress addr;
  try {
    addr = InternetAddress.fromRawAddress(value);
  } catch (_) {
    throw DecodeException('invalid ip6 value: $value');
  }
  return addr.address;
}

////////////////////////////////////////////////////////////////////////////////
// DNS* Encoder and Decoder
////////////////////////////////////////////////////////////////////////////////
Uint8List dnsEncoder(String value) => Uint8List.fromList(value.codeUnits);

String dnsDecoder(Uint8List bytes) => String.fromCharCodes(bytes);

////////////////////////////////////////////////////////////////////////////////
// UNIX Encoder and Decoder
////////////////////////////////////////////////////////////////////////////////
Uint8List unixEncoder(String value) => Uint8List.fromList(value.codeUnits);

String unixDecoder(Uint8List bytes) => String.fromCharCodes(bytes);
