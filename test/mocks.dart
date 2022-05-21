import 'package:mockito/annotations.dart';
import 'package:todos/src/data/datasources/local/todo_local_source.dart';
import 'package:todos/src/data/datasources/local/user_local_source.dart';
import 'package:todos/src/data/datasources/remote/todo_remote_source.dart';
import 'package:todos/src/domain/repositories/repositories.dart';
import 'package:todos/src/domain/usecases/usecases.dart';

export 'mocks.mocks.dart';

@GenerateMocks([
  AuthUsecases,
  UserUsecases,
  TodoUsecases,
  AuthRepository,
  UserRepository,
  TodoRepository,
  UserLocalSource,
  TodoLocalSource,
  TodoRemoteSource,
])
class Mocks {}
