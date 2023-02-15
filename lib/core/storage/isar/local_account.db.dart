import 'package:isar/isar.dart';

part 'local_account.db.g.dart';

@collection
class LocalAccount {
  LocalAccount({this.address, this.password, this.token});

  Id id = Isar.autoIncrement;

  String? address;

  String? password;

  String? token;
}
