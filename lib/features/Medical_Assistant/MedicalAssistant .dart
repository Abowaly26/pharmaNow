import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/Medical_Assistant/chat_bot/chat_bot.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'OCR/OCR.dart';

// Model for medical assistant options
class MedicalAssistantOption {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String routeName;
  final String badge;

  const MedicalAssistantOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.routeName,
    required this.badge,
  });
}

class MedicalAssistant extends StatefulWidget {
  static const String routeName = 'Medical Assistant';

  const MedicalAssistant({Key? key}) : super(key: key);

  @override
  State<MedicalAssistant> createState() => _MedicalAssistantState();
}

class _MedicalAssistantState extends State<MedicalAssistant>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _floatingAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  // Define medical assistant options with beautiful gradients
  static const List<MedicalAssistantOption> _options = [
    MedicalAssistantOption(
      title: 'AI Chat Assistant',
      description:
          'Get instant medical consultation with our advanced AI doctor',
      icon: Icons.psychology_outlined,
      gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
      routeName: ChatPage.routeName,
      badge: 'Smart',
    ),
    MedicalAssistantOption(
      title: 'Smart Document Scanner',
      description: 'Extract and analyze medical reports with AI precision',
      icon: Icons.document_scanner_outlined,
      gradientColors: [Color(0xFF11998e), Color(0xFF38ef7d)],
      routeName: PrescriptionOcrPage.routeName,
      badge: 'Pro',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _mainAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToOption(String routeName) async {
    HapticFeedback.lightImpact();
    try {
      await Navigator.pushReplacementNamed(context, routeName);
    } catch (e) {
      _showErrorSnackBar('Failed to navigate to option: $e');
    }
  }

  Future<void> _navigateBack() async {
    HapticFeedback.selectionClick();
    try {
      await Navigator.pushReplacementNamed(context, MainView.routeName);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12.w),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            _buildTitleSection(),
                            SizedBox(height: 60.h),
                            _buildOptionsSection(),
                            SizedBox(height: 40.h),
                            SizedBox(height: 40.h),
                            _buildFooter(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FAFF),
          Color(0xFFE8F4FD),
          Color(0xFFEEF7FF),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: _navigateBack,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 24.sp,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Floating decorative elements
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 20.w),
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatingAnimation.value * 0.7),
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11998e).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildLogo(),
            );
          },
        ),
        SizedBox(height: 32.h),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ).createShader(bounds),
          child: Text(
            'Medical Assistant',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            '✨ AI-Powered Healthcare Solutions',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF4A5568),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_hospital_rounded,
            color: Colors.white,
            size: 50.sp,
          ),
          Positioned(
            top: 15.h,
            right: 15.w,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: _options
          .asMap()
          .entries
          .map((entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < _options.length - 1 ? 24.h : 0,
                ),
                child: _buildOptionCard(entry.value, entry.key),
              ))
          .toList(),
    );
  }

  Widget _buildOptionCard(MedicalAssistantOption option, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 300)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 100, 0),
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: option.gradientColors.first.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24.r),
            onTap: () => _navigateToOption(option.routeName),
            child: Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: option.gradientColors.first.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  _buildOptionIcon(option),
                  SizedBox(width: 24.w),
                  Expanded(child: _buildOptionContent(option)),
                  _buildOptionArrow(option.gradientColors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionIcon(MedicalAssistantOption option) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: option.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: option.gradientColors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            option.icon,
            color: Colors.white,
            size: 32.sp,
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                option.badge,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: option.gradientColors.first,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionContent(MedicalAssistantOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          option.description,
          style: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF718096),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionArrow(List<Color> colors) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 20.sp,
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF667eea),
          size: 24.sp,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: const Color(0xFF667eea).withOpacity(0.2),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998e).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ).createShader(bounds),
              child: Text(
                'Secure & Medically Certified',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '🚀 Powered by Advanced AI Technology',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
