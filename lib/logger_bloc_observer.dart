import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class LoggerBlocObserver extends BlocObserver {
  final log = Logger('LoggerBlocObserver');
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.log(Level.INFO, '${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.log(Level.WARNING, '${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
