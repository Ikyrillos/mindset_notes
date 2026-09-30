// high level abstraction of the repository
  // business logic layer, which is good
  abstract interface class AuthRepository {

    Future<String> login(
      String email,
      String password,
    );

    // register, logout, reset password, etc
    Future<void> register(
      String email,
      String password,
    );
  }

// concrete implementation of the repository
// low level implementation of the repository, which is not good
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    if (email == '' || password == '' || email != 'user@example.com') {
      throw Exception('Invalid credentials');
    }
    return 'token';
  }

  @override
  Future<void> register(String email, String password) {
    // TODO: implement register
    throw UnimplementedError();
  }
}


// concrete implementation of the repository
// low level implementation of the repository, which is not good
class AuthRepositoryImplV2 implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
   if (email == '' || password == '') {
      throw Exception('Invalid credentials');
    }
    return 'token';
  }

  @override
  Future<void> register(String email, String password) {
    // TODO: implement register
    throw UnimplementedError();
  }

}


class LoginCubit {
  // abstract class , Contract
  final AuthRepository repository;

  LoginCubit(this.repository);


  Future<void> login(String email, String password) async {
    final token = await repository.login(email, password);
    print(token);
  }

  Future<void> register(String email, String password) async {
    await repository.register(email, password);
  }

}


final cubit = LoginCubit(
  AuthRepositoryImplV2(),
);