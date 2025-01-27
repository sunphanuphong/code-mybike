import 'dart:async';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  Timer? _timer;
  int _secondsElapsed = 0;
  final _timeController = StreamController<String>.broadcast();

  Stream<String> get timeStream => _timeController.stream;
  int get secondsElapsed => _secondsElapsed;

  void setElapsedSeconds(int seconds) {
    _secondsElapsed = seconds;
    int minutes = _secondsElapsed ~/ 60;
    int secs = _secondsElapsed % 60;
    String displayTime =
        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    _timeController.add(displayTime);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      int minutes = _secondsElapsed ~/ 60;
      int seconds = _secondsElapsed % 60;
      String displayTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      _timeController.add(displayTime);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timeController.add("00:00");
  }

  void dispose() {
    _timer?.cancel();
    _timeController.close();
  }
}
