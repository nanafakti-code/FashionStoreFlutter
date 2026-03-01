import 'package:freezed_annotation/freezed_annotation.dart';
import 'pedido_model.dart';
import 'resena_model.dart';

part 'reviewable_item_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class ReviewableItemModel with _$ReviewableItemModel {
  const factory ReviewableItemModel({
    required ItemOrdenModel item,
    required String ordenId,
    required DateTime? fechaCompra,
    @Default(false) bool estaResenado,
    ResenaModel? resenaExistente,
  }) = _ReviewableItemModel;
}
