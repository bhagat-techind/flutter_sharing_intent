#include "include/flutter_sharing_intent/flutter_sharing_intent_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_sharing_intent_plugin.h"

void FlutterSharingIntentPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_sharing_intent::FlutterSharingIntentPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
