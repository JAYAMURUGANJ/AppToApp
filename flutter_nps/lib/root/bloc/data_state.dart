// States
import 'package:equatable/equatable.dart';

abstract class DataState extends Equatable {
  const DataState();

  @override
  List<Object?> get props => [];
}

class DataInitializing extends DataState {}

class DataReady extends DataState {
  final Map<String, dynamic>? receivedData;
  final String status;
  final List<String> messageLog;
  final bool isReady;

  const DataReady({
    this.receivedData,
    required this.status,
    required this.messageLog,
    required this.isReady,
  });

  @override
  List<Object?> get props => [receivedData, status, messageLog, isReady];

  DataReady copyWith({
    Map<String, dynamic>? receivedData,
    String? status,
    List<String>? messageLog,
    bool? isReady,
  }) {
    return DataReady(
      receivedData: receivedData ?? this.receivedData,
      status: status ?? this.status,
      messageLog: messageLog ?? this.messageLog,
      isReady: isReady ?? this.isReady,
    );
  }
}

class DataError extends DataState {
  final String error;

  const DataError(this.error);

  @override
  List<Object?> get props => [error];
}
