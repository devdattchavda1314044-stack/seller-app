import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';

class ContentVideoPlayer extends StatefulWidget {
  final String? videoPath;
  final String? localVideoPath;
  final String? assetVideoPath;
  final bool autoPlay;
  final bool looping;
  final double? aspectRatio;

  const ContentVideoPlayer({
    super.key,
    this.videoPath,
    this.localVideoPath,
    this.assetVideoPath,
    this.autoPlay = true,
    this.looping = true,
    this.aspectRatio,
  });

  @override
  State<ContentVideoPlayer> createState() => _ContentVideoPlayerState();
}

class _ContentVideoPlayerState extends State<ContentVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;
  String _errorMessage = 'Unable to play this video';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(ContentVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = oldWidget.videoPath ?? oldWidget.localVideoPath ?? oldWidget.assetVideoPath;
    final newPath = widget.videoPath ?? widget.localVideoPath ?? widget.assetVideoPath;
    if (oldPath != newPath) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _isLoading = true;
      _hasError = false;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final rawPath = widget.videoPath ?? widget.localVideoPath ?? widget.assetVideoPath;
    if (rawPath == null || rawPath.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No video source provided';
        });
      }
      return;
    }

    final path = rawPath.trim();
    debugPrint('Initializing ContentVideoPlayer with path: $path');

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isInitialized = false;
      });
    }

    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else if (path.startsWith('content://')) {
        _controller = VideoPlayerController.contentUri(Uri.parse(path));
      } else if (path.startsWith('assets/') || path.startsWith('asset:')) {
        final cleanAsset = path.replaceFirst('asset:', '');
        _controller = VideoPlayerController.asset(cleanAsset);
      } else {
        // Local File Path
        String filePath = path;
        if (filePath.startsWith('file://')) {
          try {
            filePath = Uri.parse(filePath).toFilePath();
          } catch (_) {
            filePath = filePath.replaceFirst('file://', '');
          }
        }
        final file = File(filePath);
        if (!file.existsSync()) {
          debugPrint('Local video file not found at: $filePath');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'Video file not found on device';
            });
          }
          return;
        }
        _controller = VideoPlayerController.file(file);
      }

      await _controller!.initialize();
      _controller!.setLooping(widget.looping);
      await _controller!.setVolume(1.0); // HARD REQUIREMENT: Default unmuted audio

      if (widget.autoPlay) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Video Player Controller Initialization Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Unable to play this video';
        });
      }
    }
  }

  void _toggleMute() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        constraints: const BoxConstraints(minHeight: 200),
        color: const Color(0xFF111827),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError || _controller == null || !_isInitialized) {
      return Container(
        constraints: const BoxConstraints(minHeight: 200),
        color: const Color(0xFF111827),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initVideo,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videoRatio = widget.aspectRatio ?? _controller!.value.aspectRatio;
    final validRatio = videoRatio > 0 ? videoRatio : 16 / 9;

    return AspectRatio(
      aspectRatio: validRatio,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: VideoPlayer(_controller!),
            ),

          // Tap to Play / Pause Overlay
          GestureDetector(
            onTap: () {
              if (_controller != null && _isInitialized) {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_controller!.value.isPlaying)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  
                  // Subtle Mute/Unmute button top-right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

