import 'package:flutter/material.dart';

import '../services/prediction_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorText = null;
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
      setState(() => _prediction = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateInt(String? value, {required int min, required int max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a whole number';
    }
    if (parsed < min || parsed > max) {
      return 'Use $min to $max';
    }
    return null;
  }

  String? _validateDouble(String? value, {required double min, required double max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a number';
    }
    if (parsed < min || parsed > max) {
      return 'Use ${min.toInt()} to ${max.toInt()}';
    }
    return null;
  }

  @override
  void dispose() {
    _attemptsController.dispose();
    _creditsController.dispose();
    _registrationController.dispose();
    _clicksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF133A63), Color(0xFF1B6CA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Predictor',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Enter a student's demographics and learning engagement to predict their average assessment score and flag those who may need early support.",
                        style: TextStyle(
                          color: Color(0xFFE3EEF8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _InfoCard(
                  title: 'Mission',
                  description:
                      'Use demographics and learning engagement to identify students who may need support early.',
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Student Details'),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Gender',
                  initialValue: _gender,
                  items: const ['M', 'F'],
                  onChanged: (value) => setState(() => _gender = value!),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Region',
                  initialValue: _region,
                  items: const [
                    'East Anglian Region',
                    'East Midlands Region',
                    'Ireland',
                    'London Region',
                    'North Region',
                    'North Western Region',
                    'Scotland',
                    'South East Region',
                    'South Region',
                    'South West Region',
                    'Wales',
                    'West Midlands Region',
                    'Yorkshire Region',
                  ],
                  onChanged: (value) => setState(() => _region = value!),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Highest Education',
                  initialValue: _highestEducation,
                  items: const [
                    'No Formal quals',
                    'Lower Than A Level',
                    'A Level or Equivalent',
                    'HE Qualification',
                    'Post Graduate Qualification',
                  ],
                  onChanged: (value) => setState(() => _highestEducation = value!),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'IMD Band',
                  initialValue: _imdBand,
                  items: const [
                    '0-10%',
                    '10-20',
                    '20-30%',
                    '30-40%',
                    '40-50%',
                    '50-60%',
                    '60-70%',
                    '70-80%',
                    '80-90%',
                    '90-100%',
                  ],
                  onChanged: (value) => setState(() => _imdBand = value!),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Age Band',
                  initialValue: _ageBand,
                  items: const ['0-35', '35-55', '55<='],
                  onChanged: (value) => setState(() => _ageBand = value!),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Disability',
                  initialValue: _disability,
                  items: const ['N', 'Y'],
                  onChanged: (value) => setState(() => _disability = value!),
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Learning Activity'),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Previous Attempts',
                  controller: _attemptsController,
                  helperText: 'Allowed range: 0 to 6',
                  validator: (value) => _validateInt(value, min: 0, max: 6),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Studied Credits',
                  controller: _creditsController,
                  helperText: 'Allowed range: 30 to 630',
                  validator: (value) => _validateInt(value, min: 30, max: 630),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Registration Date',
                  controller: _registrationController,
                  helperText: 'Allowed range: -311 to 167',
                  validator: (value) => _validateDouble(value, min: -311, max: 167),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  label: 'Total VLE Clicks',
                  controller: _clicksController,
                  helperText: 'Allowed range: 0 to 24139',
                  validator: (value) => _validateDouble(value, min: 0, max: 24139),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading ? null : _predict,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Predict',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  _MessageCard(
                    title: 'Request Error',
                    message: _errorText!,
                    color: const Color(0xFFFF6B35),
                  ),
                ],
                if (_prediction != null) ...[
                  const SizedBox(height: 18),
                  _ResultCard(result: _prediction!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;

  const _InfoCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.initialValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppTheme.surfaceElevated,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String helperText;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _NumberField({
    required this.label,
    required this.helperText,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;

  const _MessageCard({
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(180)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

Color _bandColor(String band) {
  if (band.startsWith('Distinction')) return AppTheme.riskLow;
  if (band.startsWith('Pass')) return AppTheme.riskMedium;
  if (band.startsWith('At Risk')) return AppTheme.riskHigh;
  return AppTheme.riskCritical;
}

class _ResultCard extends StatelessWidget {
  final PredictionResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Result',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.predictedAvgScore.toStringAsFixed(2)} / 100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.performanceBand,
                  style: TextStyle(
                    color: _bandColor(result.performanceBand),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Model: ${result.modelName}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Engineered Features',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.engineeredFeatures.entries
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
