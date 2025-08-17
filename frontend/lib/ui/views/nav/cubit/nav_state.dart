part of 'nav_cubit.dart';

class NavState extends Equatable {
  const NavState({
    this.user,
    this.fetchUserStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus fetchUserStatus;
  final User? user;

  NavState copyWith({
    FormzSubmissionStatus? fetchUserStatus,
    User? user,
  }) {
    return NavState(
      fetchUserStatus: fetchUserStatus ?? this.fetchUserStatus,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [fetchUserStatus, user];
}
