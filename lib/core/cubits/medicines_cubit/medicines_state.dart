part of 'medicine_cubit.dart';

@immutable
sealed class MedicinesState {}

final class MedicinesInitial extends MedicinesState {}

final class MedicinesLoading extends MedicinesState {}

final class MedicinesFailure extends MedicinesState {
  final String errMessage;
  MedicinesFailure(this.errMessage);
}

final class MedicinesSuccess extends MedicinesState {
  final List<MedicineEntity> medicines;
  MedicinesSuccess(this.medicines);
}
