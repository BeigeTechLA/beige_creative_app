/// Immutable splash state.
///
/// `animationDone` flips true once the Lottie playback completes — the screen
/// listens and dispatches navigation. No other state surfaces because splash
/// has no user input, no API call, no error path.
class SplashState {
  final bool animationDone;

  const SplashState({this.animationDone = false});

  SplashState copyWith({bool? animationDone}) =>
      SplashState(animationDone: animationDone ?? this.animationDone);
}
