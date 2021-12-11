import 'dart:convert';

import 'package:flutter/material.dart';

class CipherAccount {
  CipherAccount({
    this.sessionId,
    this.disableAES,
    this.disableCompress,
    this.poll,
    this.accountTypeId,
    this.username,
    this.password,
    this.g,
    this.keyModulus,
    this.keyExponent,
  });

  final int? sessionId;
  final bool? disableAES;
  final bool? disableCompress;
  final bool? poll;
  final int? accountTypeId;
  final String? username;
  final String? password;
  final int? g;
  final BigInt? keyModulus;
  final BigInt? keyExponent;

  factory CipherAccount.fromRawJson(String str) => CipherAccount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CipherAccount.fromJson(Map<String, dynamic> json) => CipherAccount(
    sessionId: ~~int.parse(json["h"]),
    disableAES: json["sCrA"],
    disableCompress: json["sCoA"],
    poll: json["poll"],
    accountTypeId: json["a"],
    username: json["e"],
    password: json["f"],
    g: json["g"],
    keyModulus: BigInt.parse(json["MR"], radix: 16),
    keyExponent: BigInt.parse(json["ER"], radix: 16),
  );

  Map<String, dynamic> toJson() => {
    "h": sessionId,
    "sCrA": disableAES,
    "sCoA": disableCompress,
    "poll": poll,
    "a": accountTypeId,
    "e": username,
    "f": password,
    "g": g,
    "MR": keyModulus,
    "ER": keyExponent,
  };
}
