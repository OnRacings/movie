import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_test_project/common/di.dart';
import 'package:movie_test_project/core/network/api_caller.dart';
import 'package:movie_test_project/entities/list_movie_response_model.dart';
import 'package:movie_test_project/view_model/i_view_model/i_list_movie_view_model.dart';
import 'package:movie_test_project/view_model/view_model/list_movie_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListMovieScreen extends StatefulWidget {
  const ListMovieScreen({Key? key}) : super(key: key);

  @override
  State<ListMovieScreen> createState() => _ListMovieScreenState();
}

class _ListMovieScreenState extends State<ListMovieScreen> {
  final RefreshController _refreshController = RefreshController();
  final IListMovieViewModel _listMovieProvider = di<IListMovieViewModel>();
  final double _itemWidth = 150;
  late final double _itemHeight;
  late final double _imageHeight;

  double _spaceBetween = 0;
  double _screenWidth = 1;
  final double _minSpaceWidth = 15;
  final double _spaceHeight = 8;
  final _ratio = 0.675;
  final rootImageUrl = "https://image.tmdb.org/t/p/w500";

  @override
  void initState() {
    super.initState();
    _imageHeight = _itemWidth / _ratio;
    _itemHeight = _imageHeight + 2 * _spaceHeight;
    _listMovieProvider.refreshController = _refreshController;
    _listMovieProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Back"),
        ),
        body: ChangeNotifierProvider.value(
          value: _listMovieProvider.listMovieNotifier,
          child: Consumer(
            builder: (context, ListMovieChangeNotifier listMovieChangeNotifier,
                child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  _screenWidth = constraints.maxWidth;
                  int count = ((_screenWidth - _minSpaceWidth) /
                          (_itemWidth + _minSpaceWidth))
                      .floor();
                  _spaceBetween =
                      (_screenWidth - count * _itemWidth) / (count + 1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: _spaceBetween),
                        child: const Text(
                          "Popular list",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: _spaceBetween),
                          child: SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: true,
                              header: const WaterDropHeader(),
                              footer: CustomFooter(
                                builder:
                                    (BuildContext? context, LoadStatus? mode) {
                                  Widget body;
                                  if (mode == LoadStatus.idle) {
                                    body = Container();
                                  } else if (mode == LoadStatus.loading) {
                                    body = const CupertinoActivityIndicator();
                                  } else if (mode == LoadStatus.failed) {
                                    body =
                                        const Text("Load Failed!Click retry!");
                                  } else if (mode == LoadStatus.canLoading) {
                                    body = const Text("release to load more");
                                  } else {
                                    body = const Text("No more Data");
                                  }
                                  return Container(
                                    height: 55.0,
                                    child: Center(child: body),
                                  );
                                },
                              ),
                              controller: _refreshController,
                              onRefresh: _listMovieProvider.refresh,
                              onLoading: _listMovieProvider.loadMore,
                              child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: _itemWidth,
                                          mainAxisExtent: _itemHeight,
                                          crossAxisSpacing: _spaceBetween),
                                  itemCount: _listMovieProvider
                                          .listMovieResponseModel
                                          ?.results
                                          ?.length ??
                                      0,
                                  itemBuilder: (BuildContext ctx, index) {
                                    MovieModel item = _listMovieProvider
                                        .listMovieResponseModel!
                                        .results![index];
                                    return MovieItemWidget(
                                        itemWidth: _itemWidth,
                                        itemHeight: _itemHeight,
                                        spaceHeight: _spaceHeight,
                                        rootImageUrl: rootImageUrl,
                                        item: item,
                                        imageHeight: _imageHeight);
                                  })),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ));
  }
}

class VoteAverageWidget extends StatelessWidget {
  final double? vote;

  const VoteAverageWidget(this.vote, {Key? key}) : super(key: key);

  String _getDecimalText() {
    if (vote == null) {
      return "";
    }
    String text = vote.toString();
    int lastDot = text.indexOf(".");
    if (lastDot == -1) return "";
    return text.substring(lastDot);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(1000))),
      padding: const EdgeInsets.all(8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(vote?.round()?.toString() ?? "",
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: Text(_getDecimalText(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              )),
        ),
      ]),
    );
  }
}

class MovieItemWidget extends StatelessWidget {
  const MovieItemWidget({
    Key? key,
    required double itemWidth,
    required double itemHeight,
    required double spaceHeight,
    required this.rootImageUrl,
    required this.item,
    required double imageHeight,
  })  : _itemWidth = itemWidth,
        _itemHeight = itemHeight,
        _spaceHeight = spaceHeight,
        _imageHeight = imageHeight,
        super(key: key);

  final double _itemWidth;
  final double _itemHeight;
  final double _spaceHeight;
  final String rootImageUrl;
  final MovieModel item;
  final double _imageHeight;

  String _getReleaseYear() {
    if (item.releaseDate == null) {
      return "";
    }
    return item.releaseDate!.split("-")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: _itemWidth,
        height: _itemHeight,
        child: Column(
          children: [
            SizedBox(
              height: _spaceHeight,
            ),
            Expanded(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: rootImageUrl + (item.posterPath ?? ""),
                    height: _imageHeight,
                    width: _itemWidth,
                    imageBuilder: (context, imageProvider) => Container(
                      height: _imageHeight,
                      width: _itemWidth,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 50),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            VoteAverageWidget(item.voteAverage)
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _getReleaseYear(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        Text(item.title?.toUpperCase() ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: _spaceHeight,
            ),
          ],
        ));
  }
}
