import 'package:movie_test_project/entities/list_movie_response_model.dart';
import 'package:movie_test_project/entities/request_models/list_movie_request_params.dart';
import 'package:movie_test_project/model/entities/data_result.dart';

abstract class IMovieRepository {
  Future<ResultData<ListMovieResponseModel>>  getList(ListMoveRequestParams params);
}
