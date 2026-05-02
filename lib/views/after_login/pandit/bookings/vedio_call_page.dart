import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/agora_provider.dart';

class AgoraVideoCallScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String panditId;
  final int localUid; // your logged-in user's numeric ID
  final String panditName;
  final String? panditImage;

  const AgoraVideoCallScreen({
    super.key,
    required this.bookingId,
    required this.panditId,
    required this.localUid,
    required this.panditName,
    this.panditImage,
  });

  @override
  ConsumerState<AgoraVideoCallScreen> createState() =>
      _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends ConsumerState<AgoraVideoCallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(agoraCallProvider.notifier)
          .startVideoCall(
            panditId: widget.panditId,
            bookingId: widget.bookingId,
            localUid: widget.localUid,
          );
    });
  }

  Future<void> _onEndCall() async {
    await ref.read(agoraCallProvider.notifier).endCall();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(agoraCallProvider);
    final engine = ref.read(agoraCallProvider.notifier).engine;

    if (callState.error != null) {
      return _ErrorScreen(
        message: callState.error!,
        onBack: () => Navigator.pop(context),
      );
    }

    return PopScope(
      // Intercept back button to properly end call
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) await _onEndCall();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Remote video — full screen
            _RemoteView(
              callState: callState,
              engine: engine,
              panditName: widget.panditName,
              panditImage: widget.panditImage,
            ),

            // Local video — draggable PiP
            if (engine != null)
              _DraggablePiP(callState: callState, engine: engine),

            // Top bar
            _TopBar(
              panditName: widget.panditName,
              callState: callState,
              onBack: _onEndCall,
            ),

            // Bottom controls
            Align(
              alignment: Alignment.bottomCenter,
              child: _ControlBar(
                callState: callState,
                onMute: () => ref.read(agoraCallProvider.notifier).toggleMute(),
                onVideo: () =>
                    ref.read(agoraCallProvider.notifier).toggleVideo(),
                onSwitchCam: () =>
                    ref.read(agoraCallProvider.notifier).switchCamera(),
                onSpeaker: () =>
                    ref.read(agoraCallProvider.notifier).toggleSpeaker(),
                onEnd: _onEndCall,
              ),
            ),

            // Connecting overlay
            if (callState.isLoading)
              _LoadingOverlay(message: 'Connecting to Pandit Ji...'),
          ],
        ),
      ),
    );
  }
}

// ── Remote video ─────────────────────────────────────────────────────────────
class _RemoteView extends StatelessWidget {
  final AgoraCallState callState;
  final RtcEngine? engine;
  final String panditName;
  final String? panditImage;

  const _RemoteView({
    required this.callState,
    required this.engine,
    required this.panditName,
    this.panditImage,
  });

  @override
  Widget build(BuildContext context) {
    if (callState.remoteUid != null && engine != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine!,
          canvas: VideoCanvas(uid: callState.remoteUid),
          connection: RtcConnection(channelId: callState.channelName ?? ''),
        ),
      );
    }

    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: panditImage != null
                  ? NetworkImage(panditImage!)
                  : null,
              backgroundColor: Colors.grey.shade800,
              child: panditImage == null
                  ? const Icon(Icons.person, size: 52, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              panditName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Waiting for Pandit Ji to join...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Draggable local PiP ──────────────────────────────────────────────────────
class _DraggablePiP extends StatefulWidget {
  final AgoraCallState callState;
  final RtcEngine engine;

  const _DraggablePiP({required this.callState, required this.engine});

  @override
  State<_DraggablePiP> createState() => _DraggablePiPState();
}

class _DraggablePiPState extends State<_DraggablePiP> {
  Offset _offset = const Offset(16, 110);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 110,
            height: 160,
            child: widget.callState.isLocalVideoOn
                ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: widget.engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white54,
                        size: 28,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String panditName;
  final AgoraCallState callState;
  final VoidCallback onBack;

  const _TopBar({
    required this.panditName,
    required this.callState,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    panditName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    callState.isLoading
                        ? 'Connecting...'
                        : callState.remoteUid != null
                        ? 'In call'
                        : 'Waiting for Pandit Ji...',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Control bar ──────────────────────────────────────────────────────────────
class _ControlBar extends StatelessWidget {
  final AgoraCallState callState;
  final VoidCallback onMute;
  final VoidCallback onVideo;
  final VoidCallback onSwitchCam;
  final VoidCallback onSpeaker;
  final VoidCallback onEnd;

  const _ControlBar({
    required this.callState,
    required this.onMute,
    required this.onVideo,
    required this.onSwitchCam,
    required this.onSpeaker,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CtrlBtn(
              icon: callState.isMuted ? Icons.mic_off : Icons.mic,
              label: callState.isMuted ? 'Unmute' : 'Mute',
              active: callState.isMuted,
              onTap: onMute,
            ),
            _CtrlBtn(
              icon: callState.isLocalVideoOn
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: 'Video',
              active: !callState.isLocalVideoOn,
              onTap: onVideo,
            ),
            // End call
            GestureDetector(
              onTap: onEnd,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            _CtrlBtn(
              icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
              label: 'Speaker',
              active: false,
              onTap: onSpeaker,
            ),
            _CtrlBtn(
              icon: Icons.flip_camera_ios,
              label: 'Flip',
              active: false,
              onTap: onSwitchCam,
            ),
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: active ? Colors.white24 : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ── Loading overlay ──────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  final String message;
  const _LoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error screen ─────────────────────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorScreen({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 52),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onBack, child: const Text('Go Back')),
            ],
          ),
        ),
      ),
    );
  }
}
