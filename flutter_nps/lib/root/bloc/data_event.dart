// Events
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();

  @override
  List<Object?> get props => [];
}

class DataInitialized extends DataEvent {}

class DataReceived extends DataEvent {
  final Map<String, dynamic> data;

  const DataReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class DataRequested extends DataEvent {}

class DataCleared extends DataEvent {}

class MessageLogged extends DataEvent {
  final String message;

  const MessageLogged(this.message);

  @override
  List<Object?> get props => [message];
}

class AppLifecycleChanged extends DataEvent {
  final AppLifecycleState state;

  const AppLifecycleChanged(this.state);

  @override
  List<Object?> get props => [state];
}
