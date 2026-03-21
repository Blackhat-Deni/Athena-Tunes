import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:athena_tunes/ui/screens/Home/home_screen_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    return Obx(() => NavigationBar(
            height: 70,
            elevation: 0,
            onDestinationSelected: homeScreenController.onBottonBarTabSelected,
            selectedIndex: homeScreenController.tabIndex.toInt(),
            backgroundColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                selectedIcon: const Icon(Icons.home),
                icon: const Icon(Icons.home_outlined),
                label: modifyNgetlabel('home'.tr),
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.music_note),
                icon: const Icon(Icons.music_note_outlined),
                label: modifyNgetlabel('songs'.tr),
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.album),
                icon: const Icon(Icons.album_outlined),
                label: modifyNgetlabel('albums'.tr),
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.playlist_play),
                icon: const Icon(Icons.playlist_play_outlined),
                label: modifyNgetlabel('playlists'.tr),
              ),
            ]));
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return "${label.substring(0, 8)}..";
    }
    return label;
  }
}
