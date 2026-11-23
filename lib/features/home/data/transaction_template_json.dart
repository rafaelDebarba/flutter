/// Conversao pura do catalogo publico de modelos financeiros do SaldoZen.
///
/// Tabelas: transaction_templates, transaction_template_details,
/// transaction_template_tips e transaction_template_images.
/// Os favoritos pessoais continuam no SQLite; nao existe is_favorite
/// neste esquema publico do Supabase.
typedef PublicUrlBuilder = String Function(String storagePath);

enum TemplateTransactionType { income, expense }

enum TemplateCategory {
  salario,
  freelance,
  investimentos,
  alimentacao,
  moradia,
  transporte,
  saude,
  educacao,
  lazer,
  outros,
}

enum TemplateFrequency { one_time, weekly, monthly, yearly }

class TransactionTemplate {
  const TransactionTemplate({
    required this.id,
    required this.title,
    required this.transactionType,
    required this.category,
    required this.suggestedAmountCents,
    required this.frequency,
    required this.tags,
    required this.iconName,
    required this.imageUrl,
    required this.createdAt,
    required this.details,
    required this.tips,
    required this.images,
  });

  final String id;
  final String title;
  final TemplateTransactionType transactionType;
  final TemplateCategory category;
  final int suggestedAmountCents;
  final TemplateFrequency frequency;
  final List<String> tags;
  final String iconName;
  final String? imageUrl;
  final DateTime createdAt;
  final TransactionTemplateDetails? details;
  final List<TransactionTemplateTip> tips;
  final List<TransactionTemplateImage> images;
}

class TransactionTemplateDetails {
  const TransactionTemplateDetails({
    required this.id,
    required this.templateId,
    required this.description,
    required this.budgetingTip,
    required this.exampleNotes,
  });

  final String id;
  final String templateId;
  final String description;
  final String budgetingTip;
  final String? exampleNotes;
}

class TransactionTemplateTip {
  const TransactionTemplateTip({
    required this.id,
    required this.templateId,
    required this.position,
    required this.tipText,
  });

  final String id;
  final String templateId;
  final int position;
  final String tipText;
}

class TransactionTemplateImage {
  const TransactionTemplateImage({
    required this.id,
    required this.templateId,
    required this.position,
    required this.imageUrl,
    required this.altText,
  });

  final String id;
  final String templateId;
  final int position;
  final String imageUrl;
  final String altText;
}

/// Converte uma linha de transaction_templates, inclusive relacionamentos
/// opcionais embutidos pela API REST do Supabase.
TransactionTemplate transactionTemplateFromJson(
  Map<String, dynamic> json, {
  required PublicUrlBuilder publicUrl,
}) {
  final tips = <TransactionTemplateTip>[
    for (final item in (json['transaction_template_tips'] as List<dynamic>? ??
        const <dynamic>[]))
      transactionTemplateTipFromJson(item as Map<String, dynamic>),
  ]..sort((a, b) => a.position.compareTo(b.position));

  final images = <TransactionTemplateImage>[
    for (final item in (json['transaction_template_images'] as List<dynamic>? ??
        const <dynamic>[]))
      transactionTemplateImageFromJson(
        item as Map<String, dynamic>,
        publicUrl: publicUrl,
      ),
  ]..sort((a, b) => a.position.compareTo(b.position));

  return TransactionTemplate(
    id: json['id'] as String,
    title: json['title'] as String,
    transactionType: TemplateTransactionType.values.byName(
      json['transaction_type'] as String,
    ),
    category: TemplateCategory.values.byName(json['category'] as String),
    suggestedAmountCents: json['suggested_amount_cents'] as int,
    frequency: TemplateFrequency.values.byName(json['frequency'] as String),
    tags: List<String>.unmodifiable(
      (json['tags'] as List<dynamic>).map((item) => item as String),
    ),
    iconName: json['icon_name'] as String,
    imageUrl: _publicUrlOrNull(json['image_path'], publicUrl),
    createdAt: DateTime.parse(json['created_at'] as String),
    details: transactionTemplateDetailsFromJson(
      json['transaction_template_details'] as Map<String, dynamic>?,
    ),
    tips: List<TransactionTemplateTip>.unmodifiable(tips),
    images: List<TransactionTemplateImage>.unmodifiable(images),
  );
}

/// Converte o objeto opcional 1:1 de transaction_template_details.
TransactionTemplateDetails? transactionTemplateDetailsFromJson(
  Map<String, dynamic>? json,
) {
  if (json == null) return null;
  return TransactionTemplateDetails(
    id: json['id'] as String,
    templateId: json['template_id'] as String,
    description: json['description'] as String,
    budgetingTip: json['budgeting_tip'] as String,
    exampleNotes: json['example_notes'] as String?,
  );
}

/// Converte uma dica da tabela filha transaction_template_tips.
TransactionTemplateTip transactionTemplateTipFromJson(
  Map<String, dynamic> json,
) {
  return TransactionTemplateTip(
    id: json['id'] as String,
    templateId: json['template_id'] as String,
    position: json['position'] as int,
    tipText: json['tip_text'] as String,
  );
}

/// Converte uma imagem da tabela filha transaction_template_images.
TransactionTemplateImage transactionTemplateImageFromJson(
  Map<String, dynamic> json, {
  required PublicUrlBuilder publicUrl,
}) {
  return TransactionTemplateImage(
    id: json['id'] as String,
    templateId: json['template_id'] as String,
    position: json['position'] as int,
    imageUrl: publicUrl(json['image_path'] as String),
    altText: json['alt_text'] as String,
  );
}

String? _publicUrlOrNull(Object? value, PublicUrlBuilder publicUrl) {
  if (value is! String || value.trim().isEmpty) return null;
  return publicUrl(value);
}
