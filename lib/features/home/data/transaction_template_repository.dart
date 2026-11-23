import 'transaction_template_json.dart';

/// Contrato de leitura do catálogo público de sugestões.
///
/// Um modelo inexistente devolve null em [getTemplateById].
/// Falhas de rede, timeout, servidor ou dados inesperados lançam
/// [TransactionTemplateRepositoryException].
abstract class TransactionTemplateRepository {
  Future<List<TransactionTemplate>> getTemplates();
  Future<TransactionTemplate?> getTemplateById(String id);
}

class TransactionTemplateRepositoryException implements Exception {
  const TransactionTemplateRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'TransactionTemplateRepositoryException: $message ($cause)';
}
