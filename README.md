# SaldoZen

Aplicativo Flutter para acompanhar receitas, despesas e saldo pessoal.

## Funcionalidades

- Perfil financeiro com nome, foco financeiro e preferência por lembretes.
- Lançamentos persistidos em SQLite; os dados legados do SharedPreferences são
  importados uma única vez.
- Saldo e lista de lançamentos atualizados automaticamente com Provider.

## Desenvolvimento

- `flutter pub get`
- `flutter test`
- `flutter run`

Os lançamentos são armazenados localmente em SQLite no dispositivo e no
IndexedDB quando o app é executado na Web.
