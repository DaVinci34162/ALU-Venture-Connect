import 'package:equatable/equatable.dart';
import '../../domain/entities/startup.dart';

abstract class StartupEvent extends Equatable {
  const StartupEvent();
  @override
  List<Object?> get props => [];
}

class WatchMyStartupStarted extends StartupEvent {
  final String uid;
  const WatchMyStartupStarted(this.uid);
  @override
  List<Object?> get props => [uid];
}

class MyStartupChanged extends StartupEvent {
  final Startup? startup;
  const MyStartupChanged(this.startup);
  @override
  List<Object?> get props => [startup];
}

class CreateStartupRequested extends StartupEvent {
  final String name;
  final String description;
  final String createdBy;
  const CreateStartupRequested({
    required this.name,
    required this.description,
    required this.createdBy,
  });
  @override
  List<Object?> get props => [name, description, createdBy];
}