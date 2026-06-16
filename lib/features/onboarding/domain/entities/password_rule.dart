/// Yangi parol uchun majburiy shartlar. Har bir shart kiritilgan parolda jonli
/// tekshiriladi (Figma: yashil/kulrang nuqta). Ko‘rinadigan matn l10n’dan.
enum PasswordRule {
  /// Kamida 8 belgi.
  minLength,

  /// Katta harf (A–Z).
  upperCase,

  /// Kichik harf (a–z).
  lowerCase,

  /// Raqam (0–9).
  digit,

  /// Maxsus belgi (!@#$%...).
  special,
}

extension PasswordRuleX on PasswordRule {
  /// [value] shu shartni qondiradimi.
  bool isSatisfiedBy(String value) => switch (this) {
        PasswordRule.minLength => value.length >= 8,
        PasswordRule.upperCase => value.contains(RegExp('[A-Z]')),
        PasswordRule.lowerCase => value.contains(RegExp('[a-z]')),
        PasswordRule.digit => value.contains(RegExp('[0-9]')),
        PasswordRule.special => value.contains(RegExp(r'[^A-Za-z0-9]')),
      };
}

/// Barcha shartlar bajarilganda parol kuchli — keyingi bosqichga ruxsat.
bool isPasswordStrong(String value) =>
    PasswordRule.values.every((rule) => rule.isSatisfiedBy(value));
