import 'dart:typed_data';

import 'exception.dart';
import 'codec.dart';
import 'varint.dart';

/// A size of -1 indicates a length-prefixed variable size
const lengthPrefixed = -1;

/// A [Multiaddr] protocol enum.
///
/// Defined at [multiformats/multicodec](https://github.com/multiformats/multicodec/blob/master/table.csv).
enum Protocol {
  ip4('ip4', 0x04, 32, false, ip4Encoder, ip4Decoder),
  tcp('tcp', 0x06, 16, false, tcpEncoder, tcpDecoder),
  ip6('ip6', 0x29, 128, false, ip6Encoder, ip6Decoder),
  dns('dns', 0x35, lengthPrefixed, false, dnsEncoder, dnsDecoder),
  dns4('dns4', 0x36, lengthPrefixed, false, dnsEncoder, dnsDecoder),
  dns6('dns6', 0x37, lengthPrefixed, false, dnsEncoder, dnsDecoder),
  dnsaddr('dnsaddr', 0x38, lengthPrefixed, false, dnsEncoder, dnsDecoder),
  p2pCircuit('p2p-circuit', 0x0122, 0, false),
  unix('unix', 0x0190, lengthPrefixed, true, unixEncoder, unixDecoder),
  // TODO: wait for IPFS-related implementation in Dart
  //p2p('p2p', 0x01a5, lengthPrefixed, false),
  quic('quic', 0x01cc, 0, false),
  quicV1('quic-v1', 0x01cd, 0, false),
  ws('ws', 0x01dd, 0, false);

  /// The string representation of the protocol. E.g., ip4, tcp, etc.
  final String name;

  /// The protocol's multicodec (a normal, non-varint number).
  final int code;

  /// Varint encoded version of [code].
  Uint8List get vcode => varintEncoder(code);

  /// The size of the protocol's data field.
  ///
  /// - [size] == 0 means this protocol takes no argument.
  /// - [size] >  0 means this protocol takes a constant sized argument.
  /// - [size] <  0 means this protocol takes a variable length,
  /// varint prefixed argument.
  final int size;

  /// True if the protocol takes path arguments, and **[size] must be negative**.
  final bool hasPath;

  /// The Encoder for protocol value.
  final Encoder? valueEncoder;

  /// The Encoder and Decoder for protocol value.
  final Decoder? valueDecoder;

  const Protocol(this.name, this.code, this.size, this.hasPath,
      [this.valueEncoder, this.valueDecoder]);

  factory Protocol.fromName(String name) {
    if (_protocolNameMap.containsKey(name)) {
      return _protocolNameMap[name]!;
    }
    throw ProtocolException('protocol not found, protocol name: $name');
  }

  factory Protocol.fromCode(int code) {
    if (_protocolCodeMap.containsKey(code)) {
      return _protocolCodeMap[code]!;
    }
    throw ProtocolException('protocol not found, protocol code: $code');
  }

  factory Protocol.fromVcode(Uint8List vcode) {
    var (code, _) = varintDecoder(vcode);
    try {
      return Protocol.fromCode(code);
    } on ProtocolException {
      throw ProtocolException('protocol not found, protocol vcode: $vcode');
    }
  }

  Uint8List encodeValue(String value) {
    if (valueEncoder == null) {
      throw ProtocolException(
          'protocol $name does not support value or has not implemented valueEncoder');
    }
    return valueEncoder!(value);
  }

  String decodeValue(Uint8List bytes) {
    if (valueDecoder == null) {
      throw ProtocolException(
          'protocol $name does not support value or has not implemented valueDecoder');
    }
    return valueDecoder!(bytes);
  }
}

final _protocolNameMap = Map<String, Protocol>.unmodifiable(
    {for (var protocol in Protocol.values) protocol.name: protocol});

final _protocolCodeMap = Map<int, Protocol>.unmodifiable(
    {for (var protocol in Protocol.values) protocol.code: protocol});
