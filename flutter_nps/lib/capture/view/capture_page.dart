import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nps/capture/capture.dart';
import 'package:flutter_nps/l10n/l10n.dart';
import 'package:nps_repository/nps_repository.dart';
import 'package:platform_close/platform_close.dart';

import '../data_receiver.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({Key? key}) : super(key: key);

  static const routeName = '/capture';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaptureCubit(
        npsRepository: const NpsRepository(),
      ),
      child: const ResponsiveCard(child: CaptureView()),
    );
  }
}

class CaptureView extends StatefulWidget {
  const CaptureView({Key? key}) : super(key: key);

  @override
  State<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<CaptureView> {
  Map<String, dynamic>? _nativeData;
  static const platform = MethodChannel('com.example.myapplication/data');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your message here..")),
      );
    });
    platform.setMethodCallHandler((call) async {
      if (call.method == 'sendData') {
        final data = Map<String, dynamic>.from(
          (call.arguments as Map<dynamic, dynamic>),
        );
        debugPrint("Received from KMP: $data");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$data")),
          );
        });
        // Use the data in your widget
      }
    });

    // Load native data when the widget is initialized
    _loadNativeData();
  }

  Future<void> _loadNativeData() async {
    final data = await DataReceiver.getDataFromNative();
    if (mounted) {
      setState(() {
        _nativeData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxScore =
        context.select((CaptureCubit cubit) => cubit.state.maxScore);
    final selectedIndex =
        context.select((CaptureCubit cubit) => cubit.state.score - 1);
    final selectedChipIndexes = context.select(
      (CaptureCubit cubit) => cubit.state.chipIndexes,
    );
    final chips = [
      context.l10n.bugFreeResponse,
      context.l10n.simpleResponse,
      context.l10n.funResponse,
      context.l10n.quickResponse,
      context.l10n.greatUIResponse,
      context.l10n.responsiveResponse,
      context.l10n.friendlyResponse,
    ];
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: Spacing.xl),
                const CircleAvatar(
                  maxRadius: Spacing.xxl,
                  backgroundColor: NpsColors.colorSecondary,
                ),
                const SizedBox(height: Spacing.xl),
                Text(
                  context.l10n.captureTitle,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  context.l10n.captureMessage,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: NpsColors.colorGrey2),
                ),
                const SizedBox(height: Spacing.xl),
                if (_nativeData != null) ...[
                  Text(
                    'Native Data Received:',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    _nativeData.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
                IntrinsicWidth(
                  child: Column(
                    children: [
                      CaptureScoreSelector(
                        maxScore: maxScore,
                        selectedIndex: selectedIndex,
                        selectedCallback: (index) => context
                            .read<CaptureCubit>()
                            .selectScore(score: index + 1),
                      ),
                      const SizedBox(height: Spacing.s),
                      CaptureScoreSelectorLabels(
                        maxLabel: context.l10n.captureMaxLabel,
                        minLabel: context.l10n.captureMinLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                BlocSelector<CaptureCubit, CaptureCubitState, bool>(
                  selector: (state) => state.isScoreSelected,
                  builder: (context, isScoreSelected) {
                    return AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: !isScoreSelected
                          ? const SizedBox.shrink()
                          : ChipsPanel(
                              chips: chips,
                              selectedChipIndexes: selectedChipIndexes,
                              buttonText: context.l10n.submit,
                              canSubmit: context.select(
                                (CaptureCubit cubit) => cubit.state.canSubmit,
                              ),
                              chipToggleCallback: (index) => context
                                  .read<CaptureCubit>()
                                  .chipToggled(index: index),
                              onSubmit: () {
                                context.read<CaptureCubit>().submitResult();
                                Navigator.pushReplacementNamed(
                                  context,
                                  CaptureEndPage.routeName,
                                );
                              },
                            ),
                    );
                  },
                ),
                const SizedBox(height: Spacing.s),
              ],
            ),
          ),
        ),
        AppCloseButton(
          onPressed: PlatformClose.instance.close,
        ),
      ],
    );
  }
}

extension on CaptureCubitState {
  bool get isScoreSelected => score != -1;
  bool get canSubmit => score != -1 && chipIndexes.isNotEmpty;
}
