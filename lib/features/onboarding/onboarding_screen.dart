import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_providers.dart';
import '../../core/recurrence/frequency.dart';

const _currencies = [
  ('GBP', 'British Pound', '£'),
  ('USD', 'US Dollar', r'$'),
  ('EUR', 'Euro', '€'),
  ('CAD', 'Canadian Dollar', r'CA$'),
  ('AUD', 'Australian Dollar', r'A$'),
  ('JPY', 'Japanese Yen', '¥'),
  ('CHF', 'Swiss Franc', 'Fr'),
  ('INR', 'Indian Rupee', '₹'),
  ('SGD', 'Singapore Dollar', r'S$'),
  ('NZD', 'New Zealand Dollar', r'NZ$'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  String _currency = 'GBP';
  Frequency _frequency = Frequency.monthly;
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _page = 1);
  }

  Future<void> _done() async {
    await ref.read(settingsRepositoryProvider).completeOnboarding(
      currency: _currency,
      defaultFrequency: _frequency,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [_currencyPage(), _frequencyPage()],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _currencyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 8),
          child: Text(
            'Choose your currency',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text('Used to display all expense amounts.'),
        ),
        Expanded(
          child: ListView(
            children: _currencies
                .map((c) => RadioListTile<String>(
                      title: Text('${c.$2} (${c.$3})'),
                      subtitle: Text(c.$1),
                      value: c.$1,
                      groupValue: _currency,
                      onChanged: (v) => setState(() => _currency = v!),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _frequencyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 8),
          child: Text(
            'Default recurrence',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text('Pre-filled when you add a new expense.'),
        ),
        Expanded(
          child: ListView(
            children: Frequency.values
                .map((f) => RadioListTile<Frequency>(
                      title: Text(f.label),
                      value: f,
                      groupValue: _frequency,
                      onChanged: (v) => setState(() => _frequency = v!),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [0, 1]
                .map((i) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ))
                .toList(),
          ),
          FilledButton(
            onPressed: _page == 0 ? _next : _done,
            child: Text(_page == 0 ? 'Next' : 'Done'),
          ),
        ],
      ),
    );
  }
}
