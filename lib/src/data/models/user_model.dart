import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserSignupModel extends HiveObject {
  UserSignupModel(this.id, this.password);

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String password;
}
