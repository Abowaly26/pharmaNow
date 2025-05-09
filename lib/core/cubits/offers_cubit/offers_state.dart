part of 'offers_cubit.dart';

@immutable
sealed class OffersState {}

final class OffersInitial extends OffersState {}

final class OffersLoading extends OffersState {}

final class OffersFailure extends OffersState {
  final String errMessage;
  OffersFailure(this.errMessage);
}

final class OffersSuccess extends OffersState {
  final List<MedicineEntity> medicines;
  OffersSuccess(this.medicines);
}
