/// Base exception for all multiaddr exceptions.
abstract class BaseMultiaddrException implements Exception {
  /// The type of the exception.
  abstract final String _type;

  final String message;

  BaseMultiaddrException(this.message);

  @override
  String toString() {
    return '$_type: $message';
  }
}

/// Base exception for all varint exceptions.
abstract class VarintException extends BaseMultiaddrException {
  VarintException(String message) : super(message);
}

/// Varint exception for encoding.
class EncodeVarintException extends VarintException {
  @override
  final String _type = 'EncodeVarintException';

  EncodeVarintException(String message) : super(message);
}

/// Varint exception for decoding.
class DecodeVarintException extends VarintException {
  @override
  final String _type = 'DecodeVarintException';

  DecodeVarintException(String message) : super(message);
}

/// Protocol exception
class ProtocolException extends BaseMultiaddrException {
  @override
  final String _type = 'ProtocolException';

  ProtocolException(String message) : super(message);
}

/// Base encode and decode exception
abstract class CodecException extends BaseMultiaddrException {
  CodecException(String message) : super(message);
}

/// Encode exception
class EncodeException extends CodecException {
  @override
  final String _type = 'EncodeException';

  EncodeException(String message) : super(message);
}

/// Decode exception
class DecodeException extends CodecException {
  @override
  final String _type = 'DecodeException';

  DecodeException(String message) : super(message);
}

/// Multiaddr exception
class MultiaddrException extends BaseMultiaddrException {
  @override
  final String _type = 'MultiaddrException';

  MultiaddrException(String message) : super(message);
}
