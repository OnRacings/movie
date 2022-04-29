import 'package:flutter/material.dart';
import 'package:movie_test_project/common/di.dart';
import 'package:movie_test_project/core/common/common_function.dart';
import 'package:movie_test_project/core/common/custom_change_notifier.dart';
import 'package:movie_test_project/core/network/api_caller.dart';
import 'package:movie_test_project/core/network/base_response.dart';
import 'package:movie_test_project/entities/list_movie_response_model.dart';
import 'package:movie_test_project/entities/request_models/list_movie_request_params.dart';
import 'package:movie_test_project/model/entities/data_result.dart';
import 'package:movie_test_project/model/i_repositories/i_movie_repository.dart';
import 'package:movie_test_project/view_model/i_view_model/i_list_movie_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListMovieViewModel extends IListMovieViewModel {
  int _currentPage = 1;
  IMovieRepository movieRepository = di<IMovieRepository>();

  ListMovieViewModel() {
    listMovieNotifier = ListMovieChangeNotifier();
  }

  Future<ListMovieResponseModel?> _loadMovie(int page) async {
    ListMoveRequestParams params = ListMoveRequestParams();
    params.page = page;
    params.apiKey = "26763d7bf2e94098192e629eb975dab0";
    ResultData<ListMovieResponseModel> resultData =
        await movieRepository.getList(params);
    if (resultData is SuccessResultData) {
      if (page == 1) {
        listMovieResponseModel = resultData.data;
      } else if (isNotNullOrEmpty(resultData.data!.results)) {
        listMovieResponseModel?.results?.addAll(resultData.data!.results!);
        listMovieResponseModel?.totalPages = resultData.data!.totalPages;
        listMovieResponseModel?.totalResults = resultData.data!.totalResults;
      }
      _currentPage = page;
      listMovieNotifier.notifyListeners();
    }
    return listMovieResponseModel;
  }

  Future<ListMovieResponseModel?> refresh() async {
    ListMovieResponseModel? model = await _loadMovie(1);
    refreshController.refreshCompleted();
    return model;
  }

  Future<ListMovieResponseModel?> loadMore() async {
    ListMovieResponseModel? model;
    if (_currentPage > (listMovieResponseModel?.totalPages ?? 0)) {
      model = listMovieResponseModel;
    }
    model = await _loadMovie(_currentPage + 1);
    refreshController.loadComplete();
    return model;
  }
}

class ListMovieChangeNotifier extends CustomChangeNotifier {}
