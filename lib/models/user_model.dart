import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// UserModel — merepresentasikan row di tabel `public.users` Supabase.
///
/// Schema DB (snake_case):
///   id               UUID PRIMARY KEY
///   pokecoin_balance  INT DEFAULT 0
///   pokeball_count    INT DEFAULT 0
///   last_daily_claim  TIMESTAMPTZ (nullable)
@JsonSerializable()
class UserModel {
  final String id;

  @JsonKey(name: 'pokecoin_balance')
  final int pokecoinBalance;

  @JsonKey(name: 'pokeball_count')
  final int pokeballCount;

  @JsonKey(name: 'last_daily_claim')
  final DateTime? lastDailyClaim;

  const UserModel({
    required this.id,
    this.pokecoinBalance = 0,
    this.pokeballCount = 0,
    this.lastDailyClaim,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Shortcut untuk membuat salinan dengan field yang diubah.
  UserModel copyWith({
    String? id,
    int? pokecoinBalance,
    int? pokeballCount,
    DateTime? lastDailyClaim,
  }) {
    return UserModel(
      id: id ?? this.id,
      pokecoinBalance: pokecoinBalance ?? this.pokecoinBalance,
      pokeballCount: pokeballCount ?? this.pokeballCount,
      lastDailyClaim: lastDailyClaim ?? this.lastDailyClaim,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, coin: $pokecoinBalance, ball: $pokeballCount)';
}
