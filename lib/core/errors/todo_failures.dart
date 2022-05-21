import 'failure.dart';

class CompleteTodoFailure extends Failure {
  const CompleteTodoFailure([super.error = 'Failed to complete TODO']);
}

//------------------------------------------------------------------------------
class NotCompleteTodoFailure extends Failure {
  const NotCompleteTodoFailure([super.error = 'Failed to not complete TODO']);
}
