part of 'medicine_cubit.dart';

@immutable
sealed class MedicinesState {
  final List<MedicineEntity> medicines;
  const MedicinesState([this.medicines = const []]);
}

final class MedicinesInitial extends MedicinesState {
  const MedicinesInitial() : super(const []);
}

final class MedicinesLoading extends MedicinesState {
  const MedicinesLoading([super.medicines]);
}

final class MedicinesFailure extends MedicinesState {
  final String errMessage;
  const MedicinesFailure(this.errMessage, [super.medicines]);
}

final class MedicinesSuccess extends MedicinesState {
  const MedicinesSuccess(super.medicines);
}
