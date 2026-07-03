import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../app/routes/app_routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/storage_service.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Future<void> _onDone(BuildContext context) async {
    final storage = Get.find<StorageService>();
    await storage.saveSetting('has_seen_onboarding', true);
    if (context.mounted) context.go(AppRoutes.login);
  }

  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18.0),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).colorScheme.surface,
      imagePadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: l.onboardingPage1Title,
              body: l.onboardingPage1Body,
              image: Center(
                child: Image.asset(
                  'icons/original_transparent_3x.png',
                  width: 100,
                  height: 100,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
            PageViewModel(
              title: l.onboardingPage2Title,
              body: l.onboardingPage2Body,
              image: Center(
                child: Icon(
                  Icons.hub_outlined,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
            PageViewModel(
              title: l.onboardingPage3Title,
              body: l.onboardingPage3Body,
              image: Center(
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
            PageViewModel(
              title: l.onboardingPage4Title,
              body: l.onboardingPage4Body,
              image: Center(
                child: Icon(
                  Icons.apps_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
            PageViewModel(
              title: l.onboardingPage5Title,
              body: l.onboardingPage5Body,
              image: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
            PageViewModel(
              title: l.onboardingPage6Title,
              body: l.onboardingPage6Body,
              image: Center(
                child: Icon(
                  Icons.construction_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              decoration: _getPageDecoration(context),
            ),
          ],
          onDone: () => _onDone(context),
          onSkip: () => _onDone(context),
          showSkipButton: true,
          skip: Text(
            l.onboardingSkip,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          next: const Icon(Icons.arrow_forward),
          nextSemantic: l.onboardingNext,
          done: Text(
            l.onboardingDone,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          dotsDecorator: DotsDecorator(
            activeSize: const Size(22.0, 10.0),
            activeColor: colorScheme.primary,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            spacing: const EdgeInsets.symmetric(horizontal: 4.0),
          ),
        ),
      ),
    );
  }
}
