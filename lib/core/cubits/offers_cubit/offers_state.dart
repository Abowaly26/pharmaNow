part of 'offers_cubit.dart';

@immutable
sealed class OffersState {
  final List<MedicineEntity> medicines;
  const OffersState([this.medicines = const []]);
}

final class OffersInitial extends OffersState {
  const OffersInitial() : super(const []);
}

final class OffersLoading extends OffersState {
  const OffersLoading([super.medicines]);
}

final class OffersFailure extends OffersState {
  final String errMessage;
  const OffersFailure(this.errMessage, [super.medicines]);
}

final class OffersSuccess extends OffersState {
  const OffersSuccess(super.medicines);
}
