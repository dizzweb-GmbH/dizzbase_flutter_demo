import 'dart:async';

import 'package:dizzbase_demo/dizzbase_client/dizzbase_client.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'dizzbase_transactions.g.dart';

// For building the JSON code (generating dizzbase_transactions.g.dart), run: 
//    flutter pub run build_runner build --delete-conflicting-outputs

@JsonSerializable(explicitToJson: true)
class DizzbaseTransaction extends DizzbaseRequest
{ 
  DizzbaseTransaction();
  String transactionuuid = "";

  @JsonKey(includeToJson: false, includeFromJson: false,)
  Completer<Map<String, dynamic>>? completer;

  factory DizzbaseTransaction.fromJson(Map<String, dynamic> json) => _$DizzbaseTransactionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseTransactionToJson(this);

  void init()
  {
    completer = Completer<Map<String, dynamic>>();
    transactionuuid = const Uuid().v4();
  }
  void reset()
  {
    transactionuuid = "";
  }

  bool isRunning()
  {
    if (completer == null)
    {
      return false;
    }
    if ((completer!.isCompleted == false) && (transactionuuid != ""))
    {
      throw Exception("DizzbaseTransaction: Inconsistant state: Completer exist and is not completed, but uuid is empty.");
    }
    return (completer!.isCompleted) == false;
  }
}

@JsonSerializable(explicitToJson: true)
class DizzbaseUpdate extends DizzbaseTransaction
{
  DizzbaseUpdate ({required this.table, required this.fields, required this.values, this.filters = const []});

  final String table;
  final List<String> fields;
  final dynamic values;
  final List<Filter> filters;

  factory DizzbaseUpdate.fromJson(Map<String, dynamic> json) => _$DizzbaseUpdateFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DizzbaseInsert extends DizzbaseTransaction
{
  DizzbaseInsert ({required this.table, required this.fields, required this.values});
  final String table;
  final List<String> fields;
  final dynamic values;

  factory DizzbaseInsert.fromJson(Map<String, dynamic> json) => _$DizzbaseInsertFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseInsertToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DizzbaseDelete extends DizzbaseTransaction
{
  DizzbaseDelete ({required this.table, required this.filters});
  final String table;
  final List<Filter> filters;

  factory DizzbaseDelete.fromJson(Map<String, dynamic> json) => _$DizzbaseDeleteFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DizzbaseDeleteToJson(this);
}
