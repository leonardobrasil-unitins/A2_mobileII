import 'package:flutter/foundation.dart';

enum MainTab {
  home,
  cart,
  orders,
  profile;
}

class MainNavigationController extends ChangeNotifier {
  MainTab _currentTab;

  MainNavigationController({
    MainTab initialTab = MainTab.home,
  }) : _currentTab = initialTab;

  MainTab get currentTab => _currentTab;
  int get currentIndex => _currentTab.index;

  void selectTab(MainTab tab) {
    if (_currentTab == tab) {
      return;
    }

    _currentTab = tab;
    notifyListeners();
  }

  void selectIndex(int index) {
    if (index < 0 || index >= MainTab.values.length) {
      return;
    }

    selectTab(MainTab.values[index]);
  }
}
