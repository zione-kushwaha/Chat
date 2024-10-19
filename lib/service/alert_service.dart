import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/service/navigation_service.dart';

class AlertService {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigation;
  AlertService() {
    _navigation = _getIt.get<NavigationService>();
  }

  void showToast({required String message, IconData? icon = Icons.info}) {
    try {
      DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          builder: (context) {
            return ToastCard(
              title: Text(message),
              leading: Icon(icon),
            );
          }).show(_navigation.navigatorKey.currentContext!);
    } catch (e) {
      print(e);
    }
  }
}
