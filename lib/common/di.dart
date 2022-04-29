import 'package:get_it/get_it.dart';
import 'package:movie_test_project/model/i_repositories/i_movie_repository.dart';
import 'package:movie_test_project/model/repositories/movie_repository_impl.dart';
import 'package:movie_test_project/view_model/i_view_model/i_list_movie_view_model.dart';
import 'package:movie_test_project/view_model/view_model/list_movie_viewmodel.dart';

GetIt di = GetIt.I;

void inject() {
  di.registerFactory<IMovieRepository>(() => MovieRepository());
  di.registerFactory<IListMovieViewModel>(() => ListMovieViewModel());
}
