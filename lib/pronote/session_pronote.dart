import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'dart:math';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pronote_notification/pronote/cipher_account.dart';
import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/requests/authentification.dart';
import 'package:pronote_notification/pronote/models/requests/identification.dart';
import 'package:pronote_notification/pronote/models/requests/navigation.dart';
import 'package:pronote_notification/pronote/models/requests/params.dart';
import 'package:pronote_notification/pronote/models/response/challenge.dart';
import 'package:pronote_notification/pronote/models/response/connexion.dart';
import 'package:pronote_notification/pronote/models/response/info.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/models/response/params_user.dart';
import 'package:pronote_notification/pronote/session_http.dart';
import 'package:pronote_notification/pronote/session_http_fake.dart';

class SessionPronote {
  SessionPronote(this._casUrl, this._pronoteUrl, { useFake = false}) {
    _sessionHttp = useFake ? SessionHttpFake() : SessionHttp();
    
    if (useFake) {
      _iv = Uint8List.fromList(HEX.decode('1a1029a2367da718fafbf8fc3dd9807d'));
    } else {
      Random randomGenerator = Random.secure();
      SecureRandom random = SecureRandom('Fortuna');
      random.seed(
          KeyParameter(Uint8List.fromList(List.generate(32, (_) => randomGenerator.nextInt(255)))));
      _iv = random.nextBytes(16);
    }
  }

  // public
  late DonneesInfo params;
  late ParamsUserRessource user;
  late HomePage homePage;
  
  // private
  late final SessionHttp _sessionHttp;

  final _padding = Padding("PKCS7");
  final _md5 = Digest("MD5");
  final _sha256 = Digest("SHA-256");
  final _algorithmsAes = BlockCipher('AES/CBC');

  final String _casUrl;
  final String _pronoteUrl;
  
  late final Uint8List _iv;
  late Uint8List _aesKey = Uint8List(0);
  late CipherAccount _cipherAccount;
  
  int _nbRequest = 1;
  int _currentPage = 7;
  bool isAuthenticated = false;

  Future<void> auth(String username, String password) async {
    await _authCas(username, password);
   
    _cipherAccount = await _getCipherFromPronote();
    
    params = await _getParams();

    DonneesChallenge donneesChallenge = await _getChallengePronote();
    Uint8List computeLoginKey = _computeLoginKey(_cipherAccount.password!, donneesChallenge.alea);

    DonneesConnexion connection = await _authPronoteByChallenge(donneesChallenge.challenge!, computeLoginKey);
    
    if (connection.cle == null) {
      throw Exception('Authentification Pronote échouée');
    }

    _aesKey = _computeKeyFromChallengeResult(connection.cle!, computeLoginKey);

    user = await _getParamsUser();

    await _navigate(7);
    
    homePage = await _getHomePage();
    
    isAuthenticated = true;
  }
  
  String getUserFullName() {
    _checkIsAuthenticated();

    return user.userFullName!; 
  }
  
  String? getSchoolName() {
    _checkIsAuthenticated();

    return user.school?.nameValue?.name; 
  }

  Future<ExamsList?> getLastsMark({ refresh = false }) async {
    _checkIsAuthenticated();
    
    if (refresh) {
      homePage = await _getHomePage();
    }
    
    ExamsList? lastMarks = homePage.exams?.examsList;
    if (lastMarks != null && lastMarks.exams?.isNotEmpty == true) {
      return lastMarks;
    }

    return null;
  }
  
  void _checkIsAuthenticated() {
    if (!isAuthenticated) {
      throw Exception("Vous n\'etes pas connecté !");
    }
  }

  Future<void> _authCas(String username, String password) async {
    Response response = await _sessionHttp.get(_casUrl);

    if (response.statusCode >= 400) {
      throw Exception('Impossible d\'accéder à la page de connexion de l\'académie');
    }

    Document document = parse(response.body);

    String url = _casUrl + document.querySelector('form')!.attributes['action']!; // TODO URI builder
    List<Element> inputs = document.querySelectorAll('input');
    Map<String?, String?> map = {
      for (Element e in inputs) e.attributes['name']: e.attributes['value']
    };
    map['username'] = username;
    map['password'] = password;

    map.removeWhere((key, value) => value == null);

    response = await _sessionHttp.post(url, map);

    if (response.statusCode >= 400) {
      throw Exception('Impossible de se connecter avec vos identifiants l\'académie');
    }
  }

  Future<CipherAccount> _getCipherFromPronote() async {
    Response response = await _sessionHttp.get(_pronoteUrl + 'eleve.html?fd=1'); // TODO URI builder

    if (response.statusCode >= 400) {
      throw Exception('Impossible de récupérer les clés sur Pronote');
    }

    String responseBody = response.body;

    String body = responseBody.replaceAll(' ', '').replaceAll('\'', '"');
    String from = 'Start(';
    String to = ')}catch';

    int startJsonIndex = body.indexOf(from);
    int endJsonIndex = body.indexOf(to);
    if (startJsonIndex == -1 || endJsonIndex == -1) {
      throw Exception('Impossible de récupérer les identifiants sur Pronote');
    }

    String cipherAccountJsonRaw = body
        .substring(startJsonIndex + from.length, endJsonIndex)
        .replaceAllMapped(RegExp(r'(\w+):'), (match) {
      return '"' + match.group(1).toString() + '":';
    });

    return CipherAccount.fromRawJson(cipherAccountJsonRaw);
  }

  Future<DonneesInfo> _getParams() async {
    AsymmetricBlockCipher algorithmsRsa = AsymmetricBlockCipher('RSA/PKCS1');
    algorithmsRsa.init(true, PublicKeyParameter<RSAPublicKey>(
        RSAPublicKey(_cipherAccount.keyModulus!, _cipherAccount.keyExponent!)));

    String response = await request('FonctionParametres', RequestDonneesSec(
        donnees: DonneesParams(
            uuid: base64.encode(algorithmsRsa.process(_iv))
        )
    ));

    return RequestData<DonneesInfo>.fromRawJson(response, (json) => DonneesInfo.fromJson(json)).donneesSec!.donnees!;
  }

  Future<DonneesChallenge> _getChallengePronote() async {
    String response = await request('Identification', RequestDonneesSec(
        donnees: DonneesIdentification(
            genreConnexion: 0,
            genreEspace: _cipherAccount.accountTypeId,
            identifiant: _cipherAccount.username,
            pourEnt: true,
            enConnexionAuto: false,
            demandeConnexionAuto: false,
            demandeConnexionAppliMobile: false,
            demandeConnexionAppliMobileJeton: false,
            uuidAppliMobile: '',
            loginTokenSav: ''
        )
    ));

    return RequestData<DonneesChallenge>.fromRawJson(response, (json) => DonneesChallenge.fromJson(json)).donneesSec!.donnees!;
  }

  Future<DonneesConnexion> _authPronoteByChallenge(String challengeReceived, Uint8List key) async {
    String decryptedChallenge = _decipher(challengeReceived, key: key);
    String cleanedChallenge = _unscrambled(decryptedChallenge);
    String encryptedChallenge = _cipher(cleanedChallenge, key: key);
    
    String response = await request('Authentification', RequestDonneesSec(
        donnees: DonneesAuthentification(
            connexion: 0,
            challenge: encryptedChallenge,
            espace: _cipherAccount.accountTypeId
        )
    ));

    return RequestData<DonneesConnexion>.fromRawJson(response, (json) => DonneesConnexion.fromJson(json)).donneesSec!.donnees!;
  }
  
  Uint8List _computeKeyFromChallengeResult(String keyReceived, Uint8List key) {
    return _makeLessStupid(_decipher(keyReceived, key: key));
  }

  Future<ParamsUserRessource> _getParamsUser() async {
    String response = await request('ParametresUtilisateur', null);

    return RequestData<DonneesParamsUser>.fromRawJson(response, (json) => DonneesParamsUser.fromJson(json)).donneesSec!.donnees!.ressource!;
  }

  Future<void> _navigate(int pageIndex) async {
    await request('Navigation', RequestDonneesSec(
        donnees: DonneesNavigation(
          onglet: pageIndex,
          ongletPrec: _currentPage
        ),
        signature: RequestDonneesSignature(
          onglet: _currentPage
        ) 
    ));

    _currentPage = pageIndex;
  }

  Future<HomePage> _getHomePage() async {
    String response = await request('PageAccueil', RequestDonneesSec(
        signature: RequestDonneesSignature(
          onglet: _currentPage
        ) 
    ));

    return RequestData<HomePage>.fromRawJson(response, (json) => HomePage.fromJson(json)).donneesSec!.donnees!;
  }

  Future<String> request(String name, RequestDonneesSec? content) async {
    String order = _cipher(_nbRequest.toString(), disableIv: _nbRequest == 1);
    String url = _pronoteUrl + 'appelfonction/' + _cipherAccount.accountTypeId.toString() + '/' + _cipherAccount.sessionId.toString() + '/' + order;  // TODO URI builder

    RequestData data = RequestData(
        nom: name,
        session: _cipherAccount.sessionId,
        numeroOrdre: order,
        donneesSec: content ?? RequestDonneesSec()
    );

    debugPrint(name + ' ' + _nbRequest.toString());
    
    Response response = await _sessionHttp.post(url, data.toRawJson());

    if (response.statusCode >= 400 || response.body.contains("Erreur")) {
      throw Exception('Erreur durant la requete ' + name + ' ' + response.body);
    }

    _nbRequest += 2;

    return response.body;
  }

  BlockCipher _initCipher(bool decrypt, { Uint8List? key, disableIv = false }) {
    Uint8List ivToUse = disableIv ? Uint8List(16) : _md5.process(_iv);
    
    _algorithmsAes.reset();
    _algorithmsAes.init(!decrypt, ParametersWithIV(KeyParameter(_md5.process(key ?? _aesKey)), ivToUse));
    
    return _algorithmsAes;
  }

  Uint8List _pad(Uint8List bytes, int blockSizeBytes) {
    final padLength = blockSizeBytes - (bytes.length % blockSizeBytes);

    final padded = Uint8List(bytes.length + padLength)..setAll(0, bytes);
    _padding.addPadding(padded, bytes.length);

    return padded;
  }

  Uint8List _unpad(Uint8List padded) {
    return padded.sublist(0, padded.length - _padding.padCount(padded));
  }

  String _cipher(String data, { Uint8List? key, disableIv = false }) {
    Uint8List dataInt = _pad(Uint8List.fromList(utf8.encode(data)), 16);

    Uint8List result = Uint8List(dataInt.length);

    BlockCipher cipher = _initCipher(false, key: key, disableIv: disableIv);

    int i = 0;
    while (i < result.length) {
      i += cipher.processBlock(dataInt, i, result, i);
    }
    
    return HEX.encode(result);
  }

  String _decipher(String data, { Uint8List? key }) {
    Uint8List dataInt = Uint8List.fromList(HEX.decode(data));

    Uint8List result = Uint8List(dataInt.length);

    BlockCipher cipher = _initCipher(true, key: key);
    
    int i = 0;
    while (i < result.length) {
      i += cipher.processBlock(dataInt, i, result, i);
    }
    
    return utf8.decode(_unpad(result));
  }
  
  String _unscrambled(String data) {
    String result = '';
    
    data.split('').asMap().forEach((key, value) {
      if (key % 2 == 0) {
        result += value;
      }
    });

    return result;
  }

  Uint8List _makeLessStupid(String data) {
    // String dataString = utf8.decode(data);
    
    List<String> split = data.split(',');
    
    Uint8List result =  Uint8List(split.length);
    
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(split[i]);
    }
    
    //debugPrint('Clé : ' + data + ' soit ' + _listToString(result));
    
    return result;
  }

  Uint8List _computeLoginKey(String password, String? alea) {
    _sha256.reset();
    _sha256.update(Uint8List.fromList(utf8.encode(alea ?? '')), 0, alea?.length ?? 0);
    _sha256.update(Uint8List.fromList(utf8.encode(password)), 0, password.length);
    
    Uint8List hash = Uint8List(_sha256.digestSize) ;
    
    _sha256.doFinal(hash, 0);

    String key = HEX.encode(hash).toUpperCase();

    return Uint8List.fromList(utf8.encode(key));
  }
  
  String _listToString(Uint8List list) {
    return list.map((e) => String.fromCharCode(e)).join('');
  }
}