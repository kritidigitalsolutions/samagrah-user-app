import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/repo/agora_repo.dart';
import 'package:samagrah/utils/service/agora_config.dart';

// ── State ────────────────────────────────────────────────────────────────────
class AgoraCallState {
  final bool isJoined;
  final bool isLocalVideoOn;
  final bool isMuted;
  final bool isFrontCamera;
  final bool isSpeakerOn;
  final int? remoteUid;
  final bool isLoading;
  final String? error;
  final String? callId; // VideoCall record ID from your backend
  final String? channelName;

  const AgoraCallState({
    this.isJoined = false,
    this.isLocalVideoOn = true,
    this.isMuted = false,
    this.isFrontCamera = true,
    this.isSpeakerOn = true,
    this.remoteUid,
    this.isLoading = false,
    this.error,
    this.callId,
    this.channelName,
  });

  AgoraCallState copyWith({
    bool? isJoined,
    bool? isLocalVideoOn,
    bool? isMuted,
    bool? isFrontCamera,
    bool? isSpeakerOn,
    int? remoteUid,
    bool? isLoading,
    String? error,
    String? callId,
    String? channelName,
    bool clearRemoteUid = false,
    bool clearError = false,
  }) {
    return AgoraCallState(
      isJoined: isJoined ?? this.isJoined,
      isLocalVideoOn: isLocalVideoOn ?? this.isLocalVideoOn,
      isMuted: isMuted ?? this.isMuted,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      callId: callId ?? this.callId,
      channelName: channelName ?? this.channelName,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────
class AgoraCallNotifier extends StateNotifier<AgoraCallState> {
  final AgoraRepo _service;
  RtcEngine? _engine;

  AgoraCallNotifier(this._service) : super(const AgoraCallState());

  RtcEngine? get engine => _engine;

  /// Full flow: fetch token → start call record → join Agora channel
  Future<void> startVideoCall({
    required String panditId,
    required String bookingId, // used as channelName for uniqueness
    required int localUid,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1. Request permissions
      final camPerm = await Permission.camera.request();
      final micPerm = await Permission.microphone.request();
      if (!camPerm.isGranted || !micPerm.isGranted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Camera and microphone permissions are required.',
        );
        return;
      }

      final channelName = 'booking-$bookingId';

      // 2. Fetch Agora token from your backend
      final tokenRes = await _service.fetchToken(
        VideoTokenReqModel(
          channelName: channelName,
          uid: localUid,
          expireSeconds: 3600,
        ),
      );

      // 3. Create VideoCall record on your backend
      final callRes = await _service.startCall(
        VideoStartReqModel(
          channelName: channelName,
          calleeId: panditId,
          uid: localUid,
          meta: {'bookingId': bookingId},
        ),
      );

      state = state.copyWith(callId: callRes.id, channelName: channelName);

      // 4. Initialize Agora engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: AgoraConfig.appId));
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );
      (connection, elapsed) {
        _engine?.setEnableSpeakerphone(true); // ✅ after join
        state = state.copyWith(isJoined: true, isLoading: false);
      };

      // 5. Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            state = state.copyWith(isJoined: true, isLoading: false);
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            state = state.copyWith(remoteUid: remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            state = state.copyWith(clearRemoteUid: true);
          },
          onLeaveChannel: (connection, stats) {
            state = state.copyWith(isJoined: false, clearRemoteUid: true);
          },
          onError: (err, msg) {
            state = state.copyWith(
              isLoading: false,
              error: 'Connection error: $msg',
            );
          },
        ),
      );

      // 6. Join channel with token from backend
      await _engine!.joinChannel(
        token: tokenRes.token,
        channelId: channelName,
        uid: localUid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> endCall() async {
    try {
      // End call record on backend
      if (state.callId != null) {
        await _service.endCall(state.callId!);
      }
    } catch (_) {
      // Don't block UI if API fails
    } finally {
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
      state = const AgoraCallState();
    }
  }

  Future<void> toggleMute() async {
    final newVal = !state.isMuted;
    await _engine?.muteLocalAudioStream(newVal);
    state = state.copyWith(isMuted: newVal);
  }

  Future<void> toggleVideo() async {
    final newVal = !state.isLocalVideoOn;
    await _engine?.muteLocalVideoStream(!newVal);
    state = state.copyWith(isLocalVideoOn: newVal);
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    state = state.copyWith(isFrontCamera: !state.isFrontCamera);
  }

  Future<void> toggleSpeaker() async {
    final newVal = !state.isSpeakerOn;
    await _engine?.setEnableSpeakerphone(newVal);
    state = state.copyWith(isSpeakerOn: newVal);
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}

final agoraRepoProvider = Provider<AgoraRepo>((ref) => AgoraRepo());

final agoraCallProvider =
    StateNotifierProvider.autoDispose<AgoraCallNotifier, AgoraCallState>(
      (ref) => AgoraCallNotifier(ref.read(agoraRepoProvider)),
    );
