import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Glassmorphism Card với hiệu ứng blur tinh tế
class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double blur;
  final double opacity;
  final Border? border;

  const GlassMorphismCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor ?? Color.fromRGBO(255, 255, 255, opacity),
              borderRadius: BorderRadius.circular(borderRadius ?? 24),
              border:
                  border ??
                  Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.2),
                    width: 1.5,
                  ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF008080).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shimmer Skeleton cho loading state
class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
  });

  const ShimmerLoading.circular({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = const CircleBorder();

  const ShimmerLoading.rectangular({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape:
              shape ??
              RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(16),
              ),
        ),
      ),
    );
  }
}

/// Profile Avatar Shimmer
class ProfileAvatarShimmer extends StatelessWidget {
  const ProfileAvatarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const ShimmerLoading.circular(size: 120),
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const ShimmerLoading.rectangular(
                  width: 200,
                  height: 28,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(height: 12),
                const ShimmerLoading.rectangular(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                const SizedBox(height: 8),
                const ShimmerLoading.rectangular(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        ShimmerLoading.circular(size: 60),
                        SizedBox(height: 16),
                        ShimmerLoading.rectangular(
                          width: 80,
                          height: 32,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SizedBox(height: 8),
                        ShimmerLoading.rectangular(
                          width: 100,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        ShimmerLoading.circular(size: 60),
                        SizedBox(height: 16),
                        ShimmerLoading.rectangular(
                          width: 80,
                          height: 32,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SizedBox(height: 8),
                        ShimmerLoading.rectangular(
                          width: 100,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Form Loading Shimmer cho beneficiary_profile_form
class FormLoadingShimmer extends StatelessWidget {
  const FormLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar shimmer
          const ShimmerLoading.circular(size: 120),
          const SizedBox(height: 32),

          // Basic info card
          _buildShimmerCard(),
          const SizedBox(height: 20),

          // Guardian card
          _buildShimmerCard(),
          const SizedBox(height: 20),

          // CCCD card
          _buildShimmerCard(),
          const SizedBox(height: 20),

          // Proof files card
          _buildShimmerCard(),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading.rectangular(
            width: 150,
            height: 20,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            2,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading.rectangular(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoading.rectangular(
                    width: double.infinity,
                    height: 50,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Page Transition
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlidePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var fadeAnimation = animation.drive(fadeTween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

/// Staggered Animation cho list items
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final int delay;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = 100,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Delay dựa trên index
    Future.delayed(Duration(milliseconds: widget.index * widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
