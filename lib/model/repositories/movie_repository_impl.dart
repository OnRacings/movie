import 'package:movie_test_project/core/network/api_caller.dart';
import 'package:movie_test_project/core/network/base_response.dart';
import 'package:movie_test_project/entities/list_movie_response_model.dart';
import 'package:movie_test_project/entities/request_models/list_movie_request_params.dart';
import 'package:movie_test_project/model/entities/data_result.dart';
import 'package:movie_test_project/model/i_repositories/i_movie_repository.dart';

class MovieRepository extends IMovieRepository {
  @override
  Future<ResultData<ListMovieResponseModel>> getList(
      ListMoveRequestParams params) async {
    BaseResponse baseResponse = await BaseApiCaller.instance.get(
        "https://api.themoviedb.org/3/discover/movie", ListMovieResponseModel(),
        params: params.getParams(), isLoading: params.page == 1);
    if (baseResponse.isSuccess()) {
      return SuccessResultData<ListMovieResponseModel>(
          data: baseResponse.data, message: baseResponse.messages);
    }
    return ErrorResultData(
        status: baseResponse.status, message: baseResponse.messages);
  }
}
