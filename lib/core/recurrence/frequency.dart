enum Frequency {
  daily,
  weekly,
  biWeekly,
  monthly,
  biMonthly,
  quarterly,
  semiAnnually,
  annually,
}

extension FrequencyLabel on Frequency {
  String get label => switch (this) {
    Frequency.daily => 'Every day',
    Frequency.weekly => 'Every week',
    Frequency.biWeekly => 'Every 2 weeks',
    Frequency.monthly => 'Every month',
    Frequency.biMonthly => 'Every 2 months',
    Frequency.quarterly => 'Every 3 months',
    Frequency.semiAnnually => 'Every 6 months',
    Frequency.annually => 'Every year',
  };
}
