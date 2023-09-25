import 'package:flutter_bloc/flutter_bloc.dart';
part 'hidenavbar_state.dart';

class HideNavBarCubit extends Cubit<HideNavBarState> {
  HideNavBarCubit() : super(HideNavBarState(isVisible: false)) {
    initialHideNavBar();
  }

  bool isVisible = false;

  void initialHideNavBar() async {
    emit(HideNavBarState(isVisible: isVisible));
  }

  void updateNavBar(bool hide) async {
    isVisible = hide;
    emit(HideNavBarState(isVisible: isVisible));
  }
}
