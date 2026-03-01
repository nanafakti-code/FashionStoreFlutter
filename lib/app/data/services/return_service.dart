import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/devolucion_model.dart';

class ReturnService {
  final _supabase = Supabase.instance.client;

  Future<String?> solicitarDevolucion(String ordenId, String motivo) async {
    try {
      final String numDev = 'DEV-${DateTime.now().millisecondsSinceEpoch}';

      final res = await _supabase
          .from('devoluciones')
          .insert({
            'orden_id': ordenId,
            'numero_devolucion': numDev,
            'motivo': motivo,
            'estado': 'Pendiente',
          })
          .select('id')
          .single();

      return res['id'] as String;
    } catch (e) {
      print('Error al solicitar devolucion: $e');
      return null;
    }
  }

  Future<List<DevolucionModel>> getUserReturns(String userId) async {
    try {
      final response = await _supabase
          .from('devoluciones')
          .select('*, ordenes!inner(*, items_orden(*))')
          .eq('ordenes.usuario_id', userId)
          .order('creado_en', ascending: false);

      return (response as List)
          .map((o) => DevolucionModel.fromJson(o))
          .toList();
    } catch (e) {
      print('Error fetching returns: $e');
      return [];
    }
  }

  Future<DevolucionModel?> getReturnById(String id) async {
    try {
      final response = await _supabase
          .from('devoluciones')
          .select('*, ordenes!inner(*, items_orden(*))')
          .eq('id', id)
          .single();

      return DevolucionModel.fromJson(response);
    } catch (e) {
      print('Error fetching return by id: $e');
      return null;
    }
  }
}
