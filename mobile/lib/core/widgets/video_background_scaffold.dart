import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Scaffold reutilisable avec la video de fond (meme asset que l'onboarding)
/// et un degrade sombre pour garder le contenu lisible par-dessus.
/// Utilise sur login/register pour prolonger l'identite visuelle deja
/// posee sur l'ecran d'accueil (coherence de marque sur les ecrans d'entree).
class VideoBackgroundScaffold extends StatefulWidget {
  const VideoBackgroundScaffold({
    super.key,
    required this.child,
    this.leading,
  });

  final Widget child;
  final Widget? leading;

  @override
  State<VideoBackgroundScaffold> createState() => _VideoBackgroundScaffoldState();
}

class _VideoBackgroundScaffoldState extends State<VideoBackgroundScaffold> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/onboarding_truck.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const ColoredBox(color: Colors.black),

          // Degrade plus soutenu que sur l'onboarding : ici le fond doit
          // rester assez sombre partout pour ne jamais concurrencer la
          // carte blanche du formulaire pose par-dessus.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.black38, Colors.black87],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                if (widget.leading != null)
                  Positioned(top: 4, left: 4, child: widget.leading!),
                Positioned.fill(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
