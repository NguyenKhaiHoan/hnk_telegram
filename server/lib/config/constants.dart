import '../model/user/user.dart';

abstract final class Constants {
  static const email = 'email@example.com';
  static const password = 'password';
  static const token =
      'e1c37dfd973353b78bb71df050e2c6e72d53034e148920383968ae49b96f1fd2';
  static const userId = '15112002';
  static const name = 'Hoannk';
  static User user = User(
    id: Constants.userId,
    name: Constants.name,
    email: Constants.email,
    password: Constants.password,
    createdAt: DateTime.now(),
    profilePicture: 'https://picsum.photos/id/1/200/300',
  );
}
