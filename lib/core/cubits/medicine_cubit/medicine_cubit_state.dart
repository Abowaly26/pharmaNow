part of 'medicine_cubit.dart';

@immutable
sealed class MedicineCubitsState {}

final class MedicineCubitsInitial extends MedicineCubitsState {}

final class MedicineCubitsLoading extends MedicineCubitsState {}

final class MedicineCubitsfailure extends MedicineCubitsState {
  final String errMessage;
  MedicineCubitsfailure(this.errMessage);
}

final class MedicineCubitsSuccess extends MedicineCubitsState {
  final List<MedicineEntity> medicines;
  MedicineCubitsSuccess(this.medicines);
}
