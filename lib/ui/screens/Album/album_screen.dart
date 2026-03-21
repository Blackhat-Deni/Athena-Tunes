import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:athena_tunes/models/playling_from.dart';
import 'package:athena_tunes/models/thumbnail.dart';
import 'package:athena_tunes/ui/widgets/playlist_album_scroll_behaviour.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../../services/downloader.dart';
import '../../player/player_controller.dart';
import '../../widgets/loader.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/song_list_tile.dart';
import '../../widgets/songinfo_bottom_sheet.dart';
import '../../widgets/sort_widget.dart';
import 'album_screen_controller.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = key.hashCode.toString();
    final albumController = (Get.isRegistered<AlbumScreenController>(tag: tag))
        ? Get.find<AlbumScreenController>(tag: tag)
        : Get.put(AlbumScreenController(), tag: tag);
    final size = MediaQuery.of(context).size;
    final playerController = Get.find<PlayerController>();
    final landscape = size.width > size.height;
    final coverSize = landscape ? size.height * 0.45 : size.width * 0.60;
    return Scaffold(
      body: Column(
        children: [
          // App bar (stays fixed)
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                right: 10),
            height: 80,
            child: Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: IconButton(
                        tooltip: "back".tr,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                  ),
                  Expanded(
                    child: Obx(
                      () => Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 5),
                        id: "${albumController.album.value.title.hashCode.toString()}_appbar",
                        child: Text(
                          albumController.album.value.title,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Everything below scrolls together
          Expanded(
            child: ScrollConfiguration(
              behavior: PlaylistAlbumScrollBehaviour(),
              child: Obx(
                () => CustomScrollView(
                  slivers: [
                    // Cover image
                    SliverToBoxAdapter(
                      child: Center(
                        child: albumController.isContentFetched.isTrue
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .shadowColor
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: Thumbnail(albumController
                                            .album.value.thumbnailUrl)
                                        .extraHigh,
                                    fit: BoxFit.cover,
                                    width: coverSize,
                                    height: coverSize,
                                    errorWidget: (context, url, error) =>
                                        CachedNetworkImage(
                                      imageUrl: Thumbnail(albumController
                                              .album.value.thumbnailUrl)
                                          .high,
                                      fit: BoxFit.cover,
                                      width: coverSize,
                                      height: coverSize,
                                      placeholder: (context, url) => SizedBox(
                                        width: coverSize,
                                        height: coverSize,
                                        child: Center(
                                          child: Icon(Icons.album,
                                              size: 80,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .color),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          SizedBox(
                                        width: coverSize,
                                        height: coverSize,
                                        child: Center(
                                          child: Icon(Icons.album,
                                              size: 80,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .color),
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => SizedBox(
                                      width: coverSize,
                                      height: coverSize,
                                      child: Center(
                                        child: Icon(Icons.album,
                                            size: 80,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .color),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: coverSize,
                                height: coverSize,
                                child: const Center(
                                    child: LoadingIndicator()),
                              ),
                      ),
                    ),
                    // Title and subtitle
                    SliverToBoxAdapter(
                      child: albumController.isContentFetched.isTrue
                          ? buildTitleSubTitle(
                              context, albumController)
                          : const SizedBox.shrink(),
                    ),
                    // Action icons row
                    SliverToBoxAdapter(
                      child: albumController.isContentFetched.isTrue
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: GetPlatform.isDesktop
                                      ? 15.0
                                      : 10.0),
                              child: SizedBox(
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Obx(() => IconButton(
                                          tooltip: albumController
                                                  .isAddedToLibrary
                                                  .isFalse
                                              ? "addToLibrary".tr
                                              : "removeFromLibrary".tr,
                                          splashRadius: 10,
                                          onPressed: () {
                                            final add = albumController
                                                .isAddedToLibrary
                                                .isFalse;
                                            albumController
                                                .addNremoveFromLibrary(
                                                    albumController
                                                        .album.value,
                                                    add: add)
                                                .then((value) {
                                              if (!context.mounted)
                                                return;
                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(snackbar(
                                                      context,
                                                      value
                                                          ? add
                                                              ? "albumBookmarkAddAlert"
                                                                  .tr
                                                              : "albumBookmarkRemoveAlert"
                                                                  .tr
                                                          : "operationFailed"
                                                              .tr,
                                                      size: SanckBarSize
                                                          .MEDIUM));
                                            });
                                          },
                                          icon: Icon(albumController
                                                  .isAddedToLibrary
                                                  .isFalse
                                              ? Icons.bookmark_add
                                              : Icons
                                                  .bookmark_added))),
                                      IconButton(
                                          tooltip: "play".tr,
                                          onPressed: () {
                                            playerController
                                                .playPlayListSong(
                                                    List<MediaItem>.from(
                                                        albumController
                                                            .songList),
                                                    0,
                                                    playfrom: PlaylingFrom(
                                                        name: albumController
                                                            .album
                                                            .value
                                                            .title,
                                                        type:
                                                            PlaylingFromType
                                                                .ALBUM));
                                          },
                                          icon: Icon(
                                            Icons.play_circle,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .color,
                                          )),
                                      GetX<Downloader>(
                                          builder: (controller) {
                                        final id = albumController
                                            .album.value.browseId;
                                        return IconButton(
                                          tooltip:
                                              "downloadAlbumSongs".tr,
                                          onPressed: () {
                                            if (albumController
                                                .isDownloaded.isTrue) {
                                              return;
                                            }
                                            controller.downloadPlaylist(
                                                id,
                                                albumController.songList
                                                    .toList());
                                          },
                                          icon: albumController
                                                  .isDownloaded.isTrue
                                              ? const Icon(
                                                  Icons.download_done)
                                              : controller.playlistQueue
                                                          .containsKey(
                                                              id) &&
                                                      controller
                                                              .currentPlaylistId
                                                              .toString() ==
                                                          id
                                                  ? Stack(
                                                      children: [
                                                        Center(
                                                            child: Text(
                                                                "${controller.playlistDownloadingProgress.value}/${albumController.songList.length}",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold))),
                                                        const Center(
                                                            child:
                                                                LoadingIndicator(
                                                          dimension:
                                                              30,
                                                        ))
                                                      ],
                                                    )
                                                  : controller
                                                          .playlistQueue
                                                          .containsKey(
                                                              id)
                                                      ? const Stack(
                                                          children: [
                                                            Center(
                                                                child:
                                                                    Icon(
                                                              Icons
                                                                  .hourglass_bottom,
                                                              size: 20,
                                                            )),
                                                            Center(
                                                                child:
                                                                    LoadingIndicator(
                                                              dimension:
                                                                  30,
                                                            ))
                                                          ],
                                                        )
                                                      : const Icon(Icons
                                                          .download),
                                        );
                                      }),
                                      IconButton(
                                          tooltip: "shareAlbum".tr,
                                          visualDensity:
                                              const VisualDensity(
                                                  vertical: -3),
                                          splashRadius: 10,
                                          onPressed: () {
                                            Share.share(
                                                "https://youtube.com/playlist?list=${albumController.album.value.audioPlaylistId}");
                                          },
                                          icon: const Icon(
                                            Icons.share,
                                            size: 20,
                                          )),
                                    ],
                                  )),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 4)),
                    // Sort widget
                    SliverToBoxAdapter(
                      child: albumController.isContentFetched.isTrue
                          ? SizedBox(
                              height: albumController
                                      .isSearchingOn.isTrue
                                  ? 60
                                  : 40,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 10),
                                child: SortWidget(
                                  tag: albumController
                                      .album.value.browseId,
                                  screenController: albumController,
                                  isSearchFeatureRequired: true,
                                  itemCountTitle:
                                      "${albumController.songList.length}",
                                  itemIcon: Icons.music_note,
                                  titleLeftPadding: 9,
                                  requiredSortTypes:
                                      buildSortTypeSet(false, true),
                                  onSort: albumController.onSort,
                                  onSearch: albumController.onSearch,
                                  onSearchClose:
                                      albumController.onSearchClose,
                                  onSearchStart:
                                      albumController.onSearchStart,
                                  startAdditionalOperation:
                                      albumController
                                          .startAdditionalOperation,
                                  selectAll:
                                      albumController.selectAll,
                                  performAdditionalOperation:
                                      albumController
                                          .performAdditionalOperation,
                                  cancelAdditionalOperation:
                                      albumController
                                          .cancelAdditionalOperation,
                                ),
                              ))
                          : const SizedBox.shrink(),
                    ),
                    // Song list as slivers
                    if (albumController.isContentFetched.isFalse ||
                        albumController.songList.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child:
                              albumController.isContentFetched.isFalse
                                  ? const LoadingIndicator()
                                  : Text(
                                      "emptyPlaylist".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 200),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 5),
                                child: SongListTile(
                                    onTap: () {
                                      playerController
                                          .playPlayListSong(
                                              List<MediaItem>.from(
                                                  albumController
                                                      .songList),
                                              index,
                                              playfrom: PlaylingFrom(
                                                  name: albumController
                                                      .album
                                                      .value
                                                      .title,
                                                  type:
                                                      PlaylingFromType
                                                          .ALBUM));
                                    },
                                    song: albumController
                                        .songList[index],
                                    isPlaylistOrAlbum: true,
                                    thumbReplacementWithIndex: true,
                                    index: index + 1),
                              );
                            },
                            childCount:
                                albumController.songList.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitleSubTitle(
      BuildContext context, AlbumScreenController albumController) {
    final title = albumController.album.value.title;
    final description = albumController.album.value.description;
    final artists =
        albumController.album.value.artists?.map((e) => e['name']).join(", ") ??
            "";
    return AnimatedBuilder(
      animation: albumController.animationController,
      builder: (context, child) {
        return SizedBox(
          height: albumController.heightAnimation.value,
          child: Transform.scale(
              scale: albumController.scaleAnimation.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, bottom: 10, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Marquee(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(seconds: 5),
              id: title.hashCode.toString(),
              child: Text(
                title.length > 50 ? title.substring(0, 50) : title,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 30),
              ),
            ),
            Text(
              description ?? "",
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Marquee(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(seconds: 5),
                id: artists.hashCode.toString(),
                child: Text(
                  artists,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openBottomSheet(BuildContext context, MediaItem song) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      isScrollControlled: true,
      context: context,
      barrierColor: Colors.transparent.withAlpha(100),
      builder: (context) => SongInfoBottomSheet(song),
    ).whenComplete(() => Get.delete<SongInfoController>());
  }
}
