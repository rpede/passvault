import 'package:cryptography/cryptography.dart';

class PasswordGenerator {
  static const lower = "abcdefghijklmnopqrstuvwxyz";
  static const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const symbols = "!\";#\$%&'()*+,-./:;<=>?@[]^_`{|}~";
  static const digits = "1234567890";
  static const all = lower + upper + symbols + digits;

  static generate({int length = 16}) {
    return List.generate(
            length, (index) => SecureRandom.safe.nextInt(all.length))
        .map((e) => all[e])
        .join();
  }
}
