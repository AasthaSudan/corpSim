import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class NetworkManager {
  static final NetworkManager shared = NetworkManager._internal();
  factory NetworkManager() => shared;
  NetworkManager._internal();

  bool useMockData = true;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  String getCurrentMode() => useMockData ? 'Enhanced Mock' : 'Real Backend';

  Future<AnalysisResponse> fetchAnalysis(String sessionID) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return const AnalysisResponse(
        summary: 'Excellent negotiation! You maintained poise and used effective empathy.',
        outcome: 'Success',
        strengths: [
          AnalysisPoint(point: 'Rapport Building', explanation: 'You shifted the tone using Rose Day references.'),
          AnalysisPoint(point: 'Patience', explanation: 'You waited for the AI to make the first counter-offer.'),
        ],
        mistakes: [
          AnalysisPoint(point: 'Soft Closing', explanation: 'You could have pushed for 5% more at the end.'),
        ],
        skillGaps: ['Anchoring Tactics', 'BATNA Preparation'],
      );
    }

    try {
      final response = await _dio.get('/analyze/$sessionID');
      return AnalysisResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<APIResponse> sendToAI({
    required String scenario,
    required List<ChatMessage> messages,
    required double leverage,
    String? sessionID,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      String lastMsg = messages.last.content.toLowerCase();
      String reply = "I've heard your points, but we need to find a middle ground.";

      return APIResponse(
        opponentReply: reply,
        newLeverage: (leverage + 0.1).clamp(0.0, 1.0),
        newMood: 'happy',
        sessionId: sessionID ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
        coachTip: "Great use of empathy to shift the negotiation mood!",
      );
    }

    try {
      final payload = APIRequest(
        scenario: scenario,
        history: messages.map((e) => e.toApiMessage()).toList(),
        currentLeverage: leverage,
        sessionId: sessionID,
      );
      final response = await _dio.post('/negotiate', data: payload.toJson());
      return APIResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<SavedSession>> fetchSessions() async {
    if (useMockData) return [];
    try {
      final response = await _dio.get('/sessions');
      return (response.data['sessions'] as List).map((e) => SavedSession.fromJson(e)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  String _handleError(DioException e) => 'Connection error. Check backend or use Mock Mode.';
}

class NegotiationProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  String? _sessionID;
  double _leverage = 0.5;
  double _patience = 0.8;
  int _timeRemaining = 900;
  bool _isLoading = false;
  String? _error;
  String _mood = 'neutral';
  String? _latestCoachTip;

  List<ChatMessage> get messages => _messages;
  String? get sessionID => _sessionID;
  double get leverage => _leverage;
  double get patience => _patience;
  int get timeRemaining => _timeRemaining;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get latestCoachTip => _latestCoachTip;
  String get mood => _mood;

  void startNewSession(String scenario) {
    _messages = [ChatMessage(id: '1', content: 'Hello. Let\'s discuss the terms.', isUser: false, timestamp: DateTime.now())];
    _sessionID = null;
    _leverage = 0.5;
    _patience = 0.8;
    _timeRemaining = 900;
    notifyListeners();
  }

  Future<void> sendMessage(String scenario, String content) async {
    if (content.isEmpty) return;
    _isLoading = true;
    _messages.add(ChatMessage(id: DateTime.now().toString(), content: content, isUser: true, timestamp: DateTime.now()));
    notifyListeners();

    try {
      final response = await NetworkManager.shared.sendToAI(scenario: scenario, messages: _messages, leverage: _leverage, sessionID: _sessionID);
      _messages.add(ChatMessage(id: DateTime.now().toString(), content: response.opponentReply, isUser: false, timestamp: DateTime.now()));
      _leverage = response.newLeverage;
      _sessionID = response.sessionId;
      _latestCoachTip = response.coachTip;
      _mood = response.newMood;
    } catch (e) { _error = e.toString(); } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void endSession(SessionProvider sessionProvider, String scenarioTitle) {
    final newSavedSession = SavedSession(
      id: _sessionID ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
      scenario: scenarioTitle,
      leverage: _leverage,
      timestamp: DateTime.now().toIso8601String(),
      mood: _mood,
    );
    sessionProvider.addSessionLocally(newSavedSession);
    notifyListeners();
  }

  void decrementTime() { if (_timeRemaining > 0) { _timeRemaining--; notifyListeners(); } }
  void clearError() { _error = null; notifyListeners(); }
}

class SessionProvider with ChangeNotifier {
  List<SavedSession> _sessions = [];
  bool _isLoading = false;

  List<SavedSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  int get totalSessions => _sessions.length;
  String get hoursInvested => (_sessions.length * 0.25).toStringAsFixed(1);

  void addSessionLocally(SavedSession session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetched = await NetworkManager.shared.fetchSessions();
      if (fetched.isNotEmpty) _sessions = fetched;
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();
  SharedPreferences? _prefs;
  Future<void> init() async => _prefs = await SharedPreferences.getInstance();
  bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;
  Future<void> setLoggedIn(bool value) async => await _prefs?.setBool('is_logged_in', value);
}