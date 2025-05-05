import 'dart:io';

import 'package:pharma_now/core/enitites/medicine_entity.dart';

MedicineEntity getDummyMedicine() {
  return MedicineEntity(
    name: 'Paracetamol',
    description: 'This is a dummy description',
    code: '123456',
    quantity: 0,
    isNewProduct: true,
    price: 0,
    subabaseORImageUrl: null,
    pharmacyName: 'Pharmacy Name',
    pharmacyId: 2288,
    pharmcyAddress: 'Pharmacy Address',
    reviews: [],
    sellingCount: 10,
    discountRating: 0,
  );
}

List<MedicineEntity> getDummyMedicines() {
  return [
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
    getDummyMedicine(),
  ];
}
