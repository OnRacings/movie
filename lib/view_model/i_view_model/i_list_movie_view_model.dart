import 'package:movie_test_project/entities/list_movie_response_model.dart';
import 'package:movie_test_project/view_model/view_model/list_movie_viewmodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class IListMovieViewModel {
  ListMovieResponseModel? listMovieResponseModel;
  late ListMovieChangeNotifier listMovieNotifier;
  late RefreshController refreshController;

  Future<ListMovieResponseModel?> refresh();

  Future<ListMovieResponseModel?> loadMore();
}
