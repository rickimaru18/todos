import 'failure.dart';

class InvalidUsernameFailure extends Failure {
  const InvalidUsernameFailure([super.error = 'Invalid username']);
}

//------------------------------------------------------------------------------
class InvalidPasswordFailure extends Failure {
  const InvalidPasswordFailure([super.error = 'Invalid password']);
}

//------------------------------------------------------------------------------
class UsernameTakenFailure extends Failure {
  const UsernameTakenFailure([super.error = 'Username already taken']);
}

//------------------------------------------------------------------------------
class UsernameNotFoundFailure extends Failure {
  const UsernameNotFoundFailure([super.error = 'Username not found']);
}

//------------------------------------------------------------------------------
class IncorrectPasswordFailure extends Failure {
  const IncorrectPasswordFailure([super.error = 'Incorrect password']);
}

//------------------------------------------------------------------------------
class MaxUsersFailure extends Failure {
  const MaxUsersFailure([super.error = 'Maximum numbers of users reached']);
}
