import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: AppTheme().theme,
//       initialRoute: CapturePage.routeName,
//       debugShowCheckedModeBanner: false,
//       onGenerateRoute: RouteGenerator.generateRoute,
//       home: const Scaffold(
//         body: CapturePage(),
//       ),
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// create a another MaterialApp with for sample view
class SampleApp extends StatelessWidget {
  const SampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme().theme,
      home: const Scaffold(
        body: SamplePage(),
      ),
    );
  }
}

class SamplePage extends StatefulWidget {
  const SamplePage({super.key});

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.myapplication/data');

  Map<String, dynamic>? _receivedData;
  bool _isReady = false;
  String _status = 'Initializing...';
  final List<String> _messageLog = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupMethodChannel();
    _signalReady();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _logMessage('App resumed');
        break;
      case AppLifecycleState.paused:
        _logMessage('App paused');
        break;
      case AppLifecycleState.detached:
        _logMessage('App detached');
        break;
      case AppLifecycleState.inactive:
        _logMessage('App inactive');
        break;
      case AppLifecycleState.hidden:
        _logMessage('App hidden');
        break;
    }
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'isReady':
            _logMessage('Native checking if Flutter is ready');
            return _isReady;

          case 'sendData':
            return await _handleIncomingData(call.arguments);

          case 'warmup':
            _logMessage('Received warmup signal from native');
            return 'Flutter warmed up successfully';

          default:
            _logMessage('Unknown method: ${call.method}');
            throw PlatformException(
              code: 'Unimplemented',
              details: 'Method ${call.method} not implemented',
            );
        }
      } catch (e) {
        _logMessage('Error handling method call: $e');
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

      setState(() {
        _receivedData = data;
        _status = 'Data received successfully!';
      });

      _logMessage('Received data: ${data.length} fields');

      // Show success message
      if (mounted) {
        _showDataSnackBar(data);
      }

      // Send confirmation back to native
      await _sendConfirmationToNative(data);

      return 'Data processed successfully';
    } catch (e) {
      final error = 'Error processing data: $e';
      _logMessage(error);
      setState(() {
        _status = error;
      });
      rethrow;
    }
  }

  Future<void> _sendConfirmationToNative(Map<String, dynamic> data) async {
    try {
      await platform.invokeMethod('logMessage', {
        'message': 'Flutter processed ${data.length} data fields successfully'
      });
    } catch (e) {
      _logMessage('Failed to send confirmation to native: $e');
    }
  }

  void _signalReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isReady = true;
        _status = 'Ready to receive data';
      });
      _logMessage('Flutter page ready for communication');
    });
  }

  void _showDataSnackBar(Map<String, dynamic> data) {
    if (!mounted) return;

    final userName = data['userName'] ?? 'Unknown User';
    final userId = data['userId'] ?? 'Unknown ID';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 Received data for $userName ($userId)'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logMessage(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _messageLog.insert(0, '[$timestamp] $message');
      if (_messageLog.length > 20) {
        _messageLog.removeLast();
      }
    });
    debugPrint('SamplePage: $message');
  }

  Future<void> _requestDataFromNative() async {
    try {
      _logMessage('Requesting data from native...');
      final result = await platform.invokeMethod('getNativeData');
      _logMessage('Received response from native: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Native data: $result'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      _logMessage('Failed to get native data: $e');
    }
  }

  void _clearData() {
    setState(() {
      _receivedData = null;
      _status = 'Data cleared';
      _messageLog.clear();
    });
    _logMessage('Data and logs cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Sample Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearData,
            tooltip: 'Clear Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isReady ? Icons.check_circle : Icons.pending,
                          color: _isReady ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_status)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _requestDataFromNative,
                    icon: const Icon(Icons.download),
                    label: const Text('Get Native Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearData,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Received Data Card
            if (_receivedData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Received Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ..._buildDataRows(_receivedData!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Message Log
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message Log',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _messageLog.isEmpty
                          ? const Center(child: Text('No messages yet'))
                          : ListView.builder(
                              itemCount: _messageLog.length,
                              itemBuilder: (context, index) {
                                return Text(
                                  _messageLog[index],
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDataRows(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '${entry.key}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                _formatValue(entry.value),
                style: TextStyle(
                  color: _getValueColor(entry.value),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) {
      return 'Map (${value.length} items):\n${_formatMap(value, 1)}';
    }
    if (value is List) {
      return 'List (${value.length} items): ${value.join(', ')}';
    }
    if (value is bool) {
      return value ? '✓ true' : '✗ false';
    }
    if (value is num && value > 1000000000) {
      // Likely a timestamp
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        return '$value\n(${date.toString().substring(0, 19)})';
      } catch (e) {
        return value.toString();
      }
    }
    return value.toString();
  }

  String _formatMap(Map<dynamic, dynamic> map, int indent) {
    final spaces = '  ' * indent;
    return map.entries.map((e) {
      if (e.value is Map) {
        return '$spaces${e.key}: Map (${(e.value as Map).length} items)\n${_formatMap(e.value as Map<dynamic, dynamic>, indent + 1)}';
      }
      return '$spaces${e.key}: ${e.value}';
    }).join('\n');
  }

  Color _getValueColor(dynamic value) {
    if (value == null) return Colors.grey;
    if (value is bool) return value ? Colors.green : Colors.red;
    if (value is num) return Colors.blue;
    if (value is String) return Colors.purple;
    return Colors.black;
  }
}
