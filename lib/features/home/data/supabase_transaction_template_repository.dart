import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'transaction_template_json.dart';
import 'transaction_template_repository.dart';

/// Catálogo público e fictício. Nunca consulta lançamentos pessoais.
class SupabaseTransactionTemplateRepository
    implements TransactionTemplateRepository {
  SupabaseTransactionTemplateRepository(
    this._client, {
    this.requestTimeout = const Duration(seconds: 8),
    this.retryCount = 1,
  });

  final SupabaseClient _client;
  final Duration requestTimeout;
  final int retryCount;

  static const String imagesBucket = 'saldozen-templates';
  static const String _templateColumns =
      'id,title,transaction_type,category,suggested_amount_cents,'
      'frequency,tags,icon_name,image_path,created_at';
  static const String _templateWithDetailsColumns =
      'id,title,transaction_type,category,suggested_amount_cents,'
      'frequency,tags,icon_name,image_path,created_at,'
      'transaction_template_details(id,template_id,description,budgeting_tip,example_notes),'
      'transaction_template_tips(id,template_id,position,tip_text),'
      'transaction_template_images(id,template_id,position,image_path,alt_text)';

  @override
  Future<List<TransactionTemplate>> getTemplates() {
    return _guard('carregar as sugestões financeiras', () async {
      final rows = await _client
          .from('transaction_templates')
          .select(_templateColumns)
          .order('title', ascending: true)
          .retry(count: retryCount, requestTimeout: requestTimeout);
      return [
        for (final row in rows)
          transactionTemplateFromJson(row, publicUrl: _publicUrl),
      ];
    });
  }

  @override
  Future<TransactionTemplate?> getTemplateById(String id) {
    return _guard('carregar os detalhes da sugestão', () async {
      final row = await _client
          .from('transaction_templates')
          .select(_templateWithDetailsColumns)
          .eq('id', id)
          .maybeSingle()
          .retry(count: retryCount, requestTimeout: requestTimeout);
      return row == null
          ? null
          : transactionTemplateFromJson(row, publicUrl: _publicUrl);
    });
  }

  String _publicUrl(String path) =>
      _client.storage.from(imagesBucket).getPublicUrl(path);

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } catch (error, stackTrace) {
      debugPrint('Não foi possível $action: $error');
      Error.throwWithStackTrace(
        TransactionTemplateRepositoryException(
          'Não foi possível $action.',
          cause: error,
        ),
        stackTrace,
      );
    }
  }
}
