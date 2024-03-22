import '../infrastructure/protection.dart';
import 'credential.dart';

class OpenVault {
  List<Credential> credentials;
  Key key;
  OpenVault({required this.credentials, required this.key});
}
