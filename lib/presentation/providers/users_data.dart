import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'users_data.g.dart';

@Riverpod(keepAlive: true)
class UserPublicData extends _$UserPublicData {
  @override
  Map<String, String> build() {
    return {};
  }

  void setUserData(Map<String, String> userDataMap) {
    state.clear();
    state = {...userDataMap};
  }

  void eraseUserData() {
    state.clear();
  }
}
