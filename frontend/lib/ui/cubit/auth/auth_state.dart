part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = FormzSubmissionStatus.initial,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState copyWith({
    FormzSubmissionStatus? status,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isAuthenticated,
        errorMessage,
      ];
}
