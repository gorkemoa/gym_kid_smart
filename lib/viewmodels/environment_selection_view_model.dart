import '../models/environment_model.dart';
import '../services/environment_service.dart';
import 'base_view_model.dart';

class EnvironmentSelectionViewModel extends BaseViewModel {
  List<EnvironmentConfig> get environments =>
      EnvironmentConfig.availableEnvironments;

  Future<void> selectEnvironment(EnvironmentConfig config) async {
    await EnvironmentService.setEnvironment(config);
    notifyListeners();
  }
}
