import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Search/components/desktop_search_bar.dart';
import '/ui/screens/Search/search_screen_controller.dart';
import '/ui/widgets/animated_screen_transition.dart';

import '../Library/library.dart';
import '../Settings/settings_screen_controller.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '../../navigator.dart';
import '../../widgets/content_list_widget.dart';
import '/models/playlist.dart';

import '../../widgets/shimmer_widgets/home_shimmer.dart';
import 'home_screen_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final HomeScreenController homeScreenController =
        Get.find<HomeScreenController>();
    final SettingsScreenController settingsScreenController =
        Get.find<SettingsScreenController>();

    return Scaffold(
        floatingActionButton: Obx(
          () => ((homeScreenController.tabIndex.value == 0 &&
                          !GetPlatform.isDesktop) ||
                      homeScreenController.tabIndex.value == 3) &&
                  settingsScreenController.isBottomNavBarEnabled.isFalse
              ? Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                        bottom: playerController.playerPanelMinHeight.value >
                                Get.mediaQuery.padding.bottom
                            ? playerController.playerPanelMinHeight.value -
                                Get.mediaQuery.padding.bottom
                            : playerController.playerPanelMinHeight.value),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: FittedBox(
                        child: FloatingActionButton(
                            focusElevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))),
                            elevation: 0,
                            onPressed: () async {
                              if (homeScreenController.tabIndex.value == 3) {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const CreateNRenamePlaylistPopup());
                              } else {
                                Get.toNamed(ScreenNavigationSetup.searchScreen,
                                    id: ScreenNavigationSetup.id);
                              }
                            },
                            child: Icon(homeScreenController.tabIndex.value == 3
                                ? Icons.add
                                : Icons.search)),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: Obx(() => AnimatedScreenTransition(
            enabled:
                settingsScreenController.isTransitionAnimationDisabled.isFalse,
            resverse: homeScreenController.reverseAnimationtransiton,
            horizontalTransition: true,
            child: Center(
              key: ValueKey<int>(homeScreenController.tabIndex.value),
              child: const Body(),
            ))));
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  String _getGreeting() {
    return 'Athena Tunes';
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final size = MediaQuery.of(context).size;
    final topPadding = GetPlatform.isDesktop
        ? 85.0
        : context.isLandscape
            ? 50.0
            : size.height < 750
                ? 80.0
                : 85.0;
    const leftPadding = 20.0;
    if (homeScreenController.tabIndex.value == 0) {
      return Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // for Desktop search bar
                if (GetPlatform.isDesktop) {
                  final sscontroller = Get.find<SearchScreenController>();
                  if (sscontroller.focusNode.hasFocus) {
                    sscontroller.focusNode.unfocus();
                  }
                }
              },
              child: Obx(
                () => homeScreenController.networkError.isTrue
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 180,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "home".tr,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "networkError1".tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () {
                                            homeScreenController
                                                .loadContentFromNetwork();
                                          },
                                          child: Text(
                                            "retry".tr,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .canvasColor),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            )
                          ],
                        ),
                      )
                    : Obx(() {
                        // dispose all detachached scroll controllers
                        homeScreenController.disposeDetachedScrollControllers();
                        final items = homeScreenController
                                .isContentFetched.value
                            ? [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0,
                                      right: 15.0,
                                      bottom: 20.0,
                                      top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.settings),
                                        onPressed: () {
                                          Get.toNamed(
                                              ScreenNavigationSetup
                                                  .settingsScreen,
                                              id: ScreenNavigationSetup.id);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                          ScreenNavigationSetup.searchScreen,
                                          id: ScreenNavigationSetup.id);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.search,
                                              color: Colors.white70),
                                          const SizedBox(width: 12),
                                          Text(
                                            'searchDes'.tr,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Quick access playlists grid
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 3.2,
                                    children: [
                                      _buildQuickAccessTile(
                                        context,
                                        icon: Icons.history,
                                        label: "recentlyPlayed".tr,
                                        color: const Color(0xFF6C5CE7),
                                        playlistId: "LIBRP",
                                      ),
                                      _buildQuickAccessTile(
                                        context,
                                        icon: Icons.favorite,
                                        label: "favorites".tr,
                                        color: const Color(0xFFE17055),
                                        playlistId: "LIBFAV",
                                      ),
                                      _buildQuickAccessTile(
                                        context,
                                        icon: Icons.flight,
                                        label: "cachedOrOffline".tr,
                                        color: const Color(0xFF00B894),
                                        playlistId: "SongsCache",
                                      ),
                                      _buildQuickAccessTile(
                                        context,
                                        icon: Icons.download,
                                        label: "downloads".tr,
                                        color: const Color(0xFF0984E3),
                                        playlistId: "SongDownloads",
                                      ),
                                    ],
                                  ),
                                ),
                                // Removed QuickPicksWidget per user request
                                ...getWidgetList(
                                    homeScreenController.middleContent,
                                    homeScreenController),
                                ...getWidgetList(
                                    homeScreenController.fixedContent,
                                    homeScreenController)
                              ]
                            : [const HomeShimmer()];
                        return ListView.builder(
                          padding:
                              EdgeInsets.only(bottom: 200, top: topPadding),
                          itemCount: items.length,
                          itemBuilder: (context, index) => items[index],
                        );
                      }),
              ),
            ),
            if (GetPlatform.isDesktop)
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth > 800
                        ? 800
                        : constraints.maxWidth - 40,
                    child: const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: DesktopSearchBar()),
                  );
                }),
              )
          ],
        ),
      );
    } else if (homeScreenController.tabIndex.value == 1) {
      return const SongsLibraryWidget(isBottomNavActive: true);
    } else if (homeScreenController.tabIndex.value == 2) {
      return const PlaylistNAlbumLibraryWidget(isBottomNavActive: true);
    } else if (homeScreenController.tabIndex.value == 3) {
      return const PlaylistNAlbumLibraryWidget(
          isAlbumContent: false, isBottomNavActive: true);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildQuickAccessTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String playlistId,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final playlist = Playlist(
            title: label,
            playlistId: playlistId,
            thumbnailUrl: Playlist.thumbPlaceholderUrl,
            isCloudPlaylist: false,
          );
          Get.toNamed(
            ScreenNavigationSetup.playlistScreen,
            id: ScreenNavigationSetup.id,
            arguments: [playlist, playlistId],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getWidgetList(
      dynamic list, HomeScreenController homeScreenController) {
    return list
        .map((content) {
          final scrollController = ScrollController();
          homeScreenController.contentScrollControllers.add(scrollController);
          return ContentListWidget(
              content: content, scrollController: scrollController);
        })
        .whereType<Widget>()
        .toList();
  }
}
