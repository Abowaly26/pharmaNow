import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';

import '../../../domain/repo/entities/user_entity.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this.authRepo) : super(SignupInitial());

  final AuthRepo authRepo;
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    emit(SignupLoading());
    final result =
        await authRepo.createUserWithEmailAndPassword(email, password, name);
    result.fold(
      (failure) => emit(SignupFailure(message: failure.message)),
      (userEntity) async {
        // Send verification email after successful signup
        await authRepo.sendEmailVerification();
        emit(SignupSuccess(userEntity: userEntity));
      },
    );
  }
}
