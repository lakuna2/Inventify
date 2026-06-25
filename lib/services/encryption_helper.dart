import 'package:encrypt/encrypt.dart' as enc;

class EncryptionHelper {
  EncryptionHelper._();

  // ⚠️ Ganti dengan 32 karakter random milikmu sendiri
  // Simpan nilai ini di tempat aman (env variable / remote config)
  static const _keyString  = 'inventify_secret_key_32chars!!xx';
  static const _ivString   = 'inventify_iv_16c';

  static final _key      = enc.Key.fromUtf8(_keyString);
  static final _iv       = enc.IV.fromUtf8(_ivString);
  static final _encrypter = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
  );

  /// Enkripsi plain text → base64 string
  static String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  /// Dekripsi base64 string → plain text
  static String decrypt(String encryptedBase64) {
    return _encrypter.decrypt64(encryptedBase64, iv: _iv);
  }
}