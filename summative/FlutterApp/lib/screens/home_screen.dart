import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/prediction_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _attemptsController = TextEditingController(text: '0');
  final _creditsController = TextEditingController(text: '60');
  final _registrationController = TextEditingController(text: '-30');
  final _clicksController = TextEditingController(text: '750');

  String _gender = 'M';
  String _region = 'South Region';
  String _highestEducation = 'Lower Than A Level';
  String _imdBand = '80-90%';
  String _ageBand = '0-35';
  String _disability = 'N';

  bool _loading = false;
  String? _errorText;
  PredictionResult? _prediction;

  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _attemptsController.dispose();
    _creditsController.dispose();
    _registrationController.dispose();
    _clicksController.dispose();
    _scoreAnimController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorText = null;
      _prediction = null;
    });

    try {
      final result = await PredictionService().predict(
        gender: _gender,
        region: _region,
        highestEducation: _highestEducation,
        imdBand: _imdBand,
        ageBand: _ageBand,
        disability: _disability,
        numOfPrevAttempts: int.parse(_attemptsController.text.trim()),
        studiedCredits: int.parse(_creditsController.text.trim()),
        dateRegistration: double.parse(_registrationController.text.trim()),
        totalClicks: double.parse(_clicksController.text.trim()),
      );

      if (!mounted) return;

      _scoreAnim = Tween<double>(
        begin: 0,
        end: result.predictedAvgScore / 100,
      ).animate(CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOutCubic));
      _scoreAnimController.forward(from: 0);

      setState(() => _prediction = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateInt(String? value, {required int min, required int max}) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Whole number';
    if (parsed < min || parsed > max) return '$min – $max';
    return null;
  }

  String? _validateDouble(String? value, {required double min, required double max}) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Number';
    if (parsed < min || parsed > max) return '${min.toInt()} – ${max.toInt()}';
    return null;
  }

  Color _bandColor(String band) {
    if (band.startsWith('Distinction')) return AppTheme.riskLow;
    if (band.startsWith('Pass')) return AppTheme.riskMedium;
    if (band.startsWith('At Risk')) return AppTheme.riskHigh;
    return AppTheme.riskCritical;
  }

  String _bandAdvice(String band) {
    if (band.startsWith('Distinction')) return 'Student is on track for excellent results.';
    if (band.startsWith('Pass')) return 'Student is progressing well. Monitor engagement.';
    if (band.startsWith('At Risk')) return 'Consider reaching out with early support resources.';
    return 'Immediate intervention recommended for this student.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildSectionLabel('STUDENT BACKGROUND'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactDropdown(
                        label: 'Gender',
                        value: _gender,
                        items: const ['M', 'F'],
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactDropdown(
                        label: 'Age Band',
                        value: _ageBand,
                        items: const ['0-35', '35-55', '55<='],
                        onChanged: (v) => setState(() => _ageBand = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactDropdown(
                        label: 'Disability',
                        value: _disability,
                        items: const ['N', 'Y'],
                        onChanged: (v) => setState(() => _disability = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactDropdown(
                        label: 'IMD Band',
                        value: _imdBand,
                        items: const [
                          '0-10%', '10-20', '20-30%', '30-40%', '40-50%',
                          '50-60%', '60-70%', '70-80%', '80-90%', '90-100%',
                        ],
                        onChanged: (v) => setState(() => _imdBand = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CompactDropdown(
                  label: 'Highest Education',
                  value: _highestEducation,
                  items: const [
                    'No Formal quals',
                    'Lower Than A Level',
                    'A Level or Equivalent',
                    'HE Qualification',
                    'Post Graduate Qualification',
                  ],
                  onChanged: (v) => setState(() => _highestEducation = v!),
                ),
                const SizedBox(height: 12),
                _CompactDropdown(
                  label: 'Region',
                  value: _region,
                  items: const [
                    'East Anglian Region', 'East Midlands Region', 'Ireland',
                    'London Region', 'North Region', 'North Western Region',
                    'Scotland', 'South East Region', 'South Region',
                    'South West Region', 'Wales', 'West Midlands Region',
                    'Yorkshire Region',
                  ],
                  onChanged: (v) => setState(() => _region = v!),
                ),
                const SizedBox(height: 28),
                _buildSectionLabel('LEARNING ACTIVITY'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactNumberField(
                        label: 'Prev. Attempts',
                        hint: '0 – 6',
                        controller: _attemptsController,
                        validator: (v) => _validateInt(v, min: 0, max: 6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactNumberField(
                        label: 'Credits',
                        hint: '30 – 630',
                        controller: _creditsController,
                        validator: (v) => _validateInt(v, min: 30, max: 630),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactNumberField(
                        label: 'Reg. Date (days)',
                        hint: '-311 – 167',
                        controller: _registrationController,
                        validator: (v) => _validateDouble(v, min: -311, max: 167),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactNumberField(
                        label: 'VLE Clicks',
                        hint: '0 – 24139',
                        controller: _clicksController,
                        validator: (v) => _validateDouble(v, min: 0, max: 24139),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loading ? null : _predict,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.accent.withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Predicting…',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : const Text(
                            'Predict',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _errorText!),
                ],
                if (_prediction != null) ...[
                  const SizedBox(height: 28),
                  _ResultCard(
                    result: _prediction!,
                    scoreAnim: _scoreAnim,
                    bandColor: _bandColor(_prediction!.performanceBand),
                    advice: _bandAdvice(_prediction!.performanceBand),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'EduSense',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Predict a student\'s assessment score from demographics\nand engagement to flag who needs early support.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── Compact dropdown ────────────────────────────────────────────────────────

class _CompactDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownColor: AppTheme.surfaceElevated,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─── Compact number field ─────────────────────────────────────────────────────

class _CompactNumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _CompactNumberField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.riskCritical.withAlpha(120)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.riskCritical, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score arc painter ────────────────────────────────────────────────────────

class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreArcPainter({required this.progress, required this.color}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = const Color(0xFF2A2A38)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final PredictionResult result;
  final Animation<double> scoreAnim;
  final Color bandColor;
  final String advice;

  const _ResultCard({
    required this.result,
    required this.scoreAnim,
    required this.bandColor,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Score dial
          AnimatedBuilder(
            animation: scoreAnim,
            builder: (context, _) {
              return SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _ScoreArcPainter(
                    progress: scoreAnim.value,
                    color: bandColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (scoreAnim.value * 100).toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          'out of 100',
                          style: TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Band pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bandColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bandColor.withAlpha(80)),
            ),
            child: Text(
              result.performanceBand,
              style: TextStyle(
                color: bandColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Divider
          Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 14),
          // Advice row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: bandColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  advice,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Model label
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Model: ${result.modelName}',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
