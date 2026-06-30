import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/opportunities/data/datasources/opportunity_firestore_datasource.dart';
import '../../features/opportunities/data/repositories/opportunity_repository_impl.dart';
import '../../features/opportunities/domain/repositories/opportunity_repository.dart';
import '../../features/opportunities/domain/usecases/close_opportunity.dart';
import '../../features/opportunities/domain/usecases/create_opportunity.dart';
import '../../features/opportunities/domain/usecases/update_opportunity.dart';
import '../../features/opportunities/domain/usecases/watch_open_opportunities.dart';
import '../../features/opportunities/presentation/bloc/opportunity_bloc.dart';
import '../../features/startup_profile/data/datasources/startup_firestore_datasource.dart';
import '../../features/startup_profile/data/repositories/startup_repository_impl.dart';
import '../../features/startup_profile/domain/repositories/startup_repository.dart';
import '../../features/startup_profile/domain/usecases/create_startup.dart';
import '../../features/startup_profile/domain/usecases/watch_my_startup.dart';
import '../../features/startup_profile/presentation/bloc/startup_bloc.dart';

final sl = GetIt.instance; // "service locator" — conventional name for the get_it singleton

/// Called once at app startup, before runApp(). Registers every dependency
/// from the bottom of the dependency graph up: external packages first,
/// then data sources, then repositories, then use cases, then BLoCs.
Future<void> initDependencies() async {
  // ---- external ----
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<fb_auth.FirebaseAuth>(() => fb_auth.FirebaseAuth.instance);

  // ---- auth feature ----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl(), sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => WatchAuthState(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton(
    () => AuthBloc(
      watchAuthState: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
    ),
  );

  // ---- startup_profile feature ----
  sl.registerLazySingleton<StartupFirestoreDataSource>(
    () => StartupFirestoreDataSource(sl()),
  );

  sl.registerLazySingleton<StartupRepository>(
    () => StartupRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => WatchMyStartup(sl()));
  sl.registerLazySingleton(() => CreateStartup(sl()));

  sl.registerFactory(
    () => StartupBloc(watchMyStartup: sl(), createStartup: sl()),
  );

  // ---- opportunities feature ----
  sl.registerLazySingleton<OpportunityFirestoreDataSource>(
        () => OpportunityFirestoreDataSource(sl()),
  );

  sl.registerLazySingleton<OpportunityRepository>(
        () => OpportunityRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => WatchOpenOpportunities(sl()));
  sl.registerLazySingleton(() => CreateOpportunity(sl()));
  sl.registerLazySingleton(() => UpdateOpportunity(sl()));
  sl.registerLazySingleton(() => CloseOpportunity(sl()));

  // BLoCs are registered as a factory, not a singleton — every time a
  // screen requests one, it gets a fresh instance with its own
  // subscriptions and lifecycle, rather than reusing a stale one.
  sl.registerFactory(
        () => OpportunityBloc(
      watchOpenOpportunities: sl(),
      createOpportunity: sl(),
      closeOpportunity: sl(),
    ),
  );
}