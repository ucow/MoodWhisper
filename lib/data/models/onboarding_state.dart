/// Represents the onboarding state for a user
class OnboardingState {
  final bool isCompleted;
  final DateTime? completedAt;
  final int currentStep;

  const OnboardingState({
    required this.isCompleted,
    this.completedAt,
    this.currentStep = 0,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(
      isCompleted: false,
      completedAt: null,
      currentStep: 0,
    );
  }

  factory OnboardingState.completed() {
    return OnboardingState(
      isCompleted: true,
      completedAt: DateTime.now(),
      currentStep: 3,
    );
  }

  OnboardingState copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    int? currentStep,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'currentStep': currentStep,
    };
  }

  factory OnboardingState.fromMap(Map<String, dynamic> map) {
    return OnboardingState(
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
      currentStep: map['currentStep'] as int? ?? 0,
    );
  }
}
