import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:todos/src/data/models/todo_model.dart';

part 'todo_remote_source.g.dart';

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class TodoRemoteSource {
  factory TodoRemoteSource(
    Dio dio, {
    String baseUrl,
  }) = _TodoRemoteSource;

  @GET("/todos")
  Future<List<TodoModel>> getTodos();
}
