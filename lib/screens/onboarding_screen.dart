import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Catat Tradingmu\nDengan Mudah!',
      description: 'Pencatatan mudah dengan penggunaan\nyang ramah pengguna.',
      buttonLabel: 'LANJUTKAN',
    ),
    _OnboardingData(
      title: 'Trading Lebih\nDisiplin!',
      description: 'Terapkan rencana tradingmu\ndengan disiplin.',
      buttonLabel: 'MULAI JURNALCUAN',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: _pages[i],
          onNext: _nextPage,
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String buttonLabel;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.buttonLabel,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final VoidCallback onNext;

  const _OnboardingPage({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D3B2E),
            Color(0xFF081C15),
            Color(0xFF050D0A),
            AppTheme.primaryDark,
          ],
          stops: [0.0, 0.35, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Center(
              child: Icon(
                Icons.trending_up_rounded,
                color: AppTheme.primaryGreen,
                size: 32,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 0.5,
                    color: Colors.white12,
                    margin: const EdgeInsets.only(bottom: 28),
                  ),
                  Text(
                    data.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 0.5,
                    color: Colors.white12,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: onNext,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.buttonLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}