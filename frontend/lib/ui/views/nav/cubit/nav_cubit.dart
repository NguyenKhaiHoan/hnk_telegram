import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:telegram_frontend/data/repositories/auth/auth_repository.dart';
import 'package:telegram_frontend/domain/models/user.dart';

part 'nav_state.dart';

class NavCubit extends Cubit<NavState> {
  NavCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const NavState());

  final AuthRepository _authRepository;

  void initialize() {
    fetchUser();
  }

  Future<void> fetchUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        emit(state.copyWith(fetchUserStatus: FormzSubmissionStatus.failure));
      },
      (user) {
        emit(
          state.copyWith(
            fetchUserStatus: FormzSubmissionStatus.success,
            user: user,
          ),
        );
      },
    );
  }
}
