part of 'best_selling_cubit.dart';

@immutable
sealed class BestSellingState {}

final class BestSellingInitial extends BestSellingState {}

final class BestSellingLoading extends BestSellingState {}

final class BestSellingFailure extends BestSellingState {
  final String errMessage;
  BestSellingFailure(this.errMessage);
}

final class BestSellingSuccess extends BestSellingState {
  final List<MedicineEntity> medicines;
  BestSellingSuccess(this.medicines);
}
