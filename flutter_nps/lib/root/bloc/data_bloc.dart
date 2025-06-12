// BLoC
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data_event.dart';
import 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  static const platform = MethodChannel('com.example.myapplication/data');

  DataBloc() : super(DataInitializing()) {
    on<DataInitialized>(_onDataInitialized);
    on<DataReceived>(_onDataReceived);
    on<DataRequested>(_onDataRequested);
    on<DataCleared>(_onDataCleared);
    on<MessageLogged>(_onMessageLogged);
    on<AppLifecycleChanged>(_onAppLifecycleChanged);

    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'isReady':
            add(const MessageLogged('Native checking if Flutter is ready'));
            return state is DataReady ? (state as DataReady).isReady : false;

          case 'sendData':
            return await _handleIncomingData(call.arguments);

          case 'warmup':
            add(const MessageLogged('Received warmup signal from native'));
            return 'Flutter warmed up successfully';

          default:
            add(MessageLogged('Unknown method: ${call.method}'));
            throw PlatformException(
              code: 'Unimplemented',
              details: 'Method ${call.method} not implemented',
            );
        }
      } catch (e) {
        add(MessageLogged('Error handling method call: $e'));
        rethrow;
      }
    });
  }

  Future<String> _handleIncomingData(dynamic arguments) async {
    try {
      if (arguments == null) {
        throw ArgumentError('No data received');
      }

      final data = Map<String, dynamic>.from(
        arguments is Map ? arguments : <String, dynamic>{},
      );

      add(DataReceived(data));
      add(MessageLogged('Received data: ${data.length} fields'));

      // Send confirmation back to native
      await _sendConfirmationToNative(data);

      return 'Data processed successfully';
    } catch (e) {
      final error = 'Error processing data: $e';
      add(MessageLogged(error));
      emit(DataError(error));
      rethrow;
    }
  }

  Future<void> _sendConfirmationToNative(Map<String, dynamic> data) async {
    try {
      await platform.invokeMethod('logMessage', {
        'message': 'Flutter processed ${data.length} data fields successfully'
      });
    } catch (e) {
      add(MessageLogged('Failed to send confirmation to native: $e'));
    }
  }

  void _onDataInitialized(DataInitialized event, Emitter<DataState> emit) {
    emit(const DataReady(
      status: 'Ready to receive data',
      messageLog: ['Flutter page ready for communication'],
      isReady: true,
    ));
  }

  void _onDataReceived(DataReceived event, Emitter<DataState> emit) {
    if (state is DataReady) {
      final currentState = state as DataReady;
      emit(currentState.copyWith(
        receivedData: event.data,
        status: 'Data received successfully!',
      ));
    }
  }

  void _onDataRequested(DataRequested event, Emitter<DataState> emit) async {
    try {
      add(const MessageLogged('Requesting data from native...'));
      final result = await platform.invokeMethod('getNativeData');
      add(MessageLogged('Received response from native: $result'));
    } catch (e) {
      add(MessageLogged('Failed to get native data: $e'));
    }
  }

  void _onDataCleared(DataCleared event, Emitter<DataState> emit) {
    if (state is DataReady) {
      emit(const DataReady(
        receivedData: null,
        status: 'Data cleared',
        messageLog: ['Data and logs cleared'],
        isReady: true,
      ));
    }
  }

  void _onMessageLogged(MessageLogged event, Emitter<DataState> emit) {
    if (state is DataReady) {
      final currentState = state as DataReady;
      final timestamp = DateTime.now().toString().substring(11, 19);
      final newMessage = '[$timestamp] ${event.message}';
      final updatedLog = [newMessage, ...currentState.messageLog];

      // Keep only last 20 messages
      if (updatedLog.length > 20) {
        updatedLog.removeLast();
      }

      emit(currentState.copyWith(messageLog: updatedLog));
    }
  }

  void _onAppLifecycleChanged(
      AppLifecycleChanged event, Emitter<DataState> emit) {
    String message;
    switch (event.state) {
      case AppLifecycleState.resumed:
        message = 'App resumed';
        break;
      case AppLifecycleState.paused:
        message = 'App paused';
        break;
      case AppLifecycleState.detached:
        message = 'App detached';
        break;
      case AppLifecycleState.inactive:
        message = 'App inactive';
        break;
      case AppLifecycleState.hidden:
        message = 'App hidden';
        break;
    }
    add(MessageLogged(message));
  }
}
