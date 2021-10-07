import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voximplant Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Voximplant video recorder'),
    );
  }
}

enum AppState { initialising, error, ready, recording }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final VIClient _client = Voximplant().getClient();
  VICall? _call;
  AppState _state = AppState.initialising;

  @override
  initState() {
    super.initState();
    _login();
  }

  void _login() async {
    try {
      await _client.connect();
      await _client.login(dotenv.get('USER'), dotenv.get('PASSWORD'));
      setState(() {});
      _state = AppState.ready;
    } on Exception catch (e) {
      log(e.toString());
      setState(() {
        _state = AppState.error;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _logout();
  }

  Future<void> _logout() async {
    final state = await _client.getClientState();
    if (state != VIClientState.Disconnected) _client.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getBody(_state),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _getActionButton(_state),
      bottomNavigationBar: BottomAppBar(
        child: Container(
            margin: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: const SizedBox(
              height: 40,
            )),
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
      ),
    );
  }

  Widget _getBody(AppState state) {
    switch (state) {
      case AppState.initialising:
        return const Center(child: CircularProgressIndicator());
      case AppState.ready:
        return const Center(child: Text("Press Record button to record video"));
      case AppState.error:
        return Container(
          decoration: const BoxDecoration(color: Colors.red),
          child: const Center(
            child: Text(
              "Error",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      case AppState.recording:
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Text('Recording. Press stop button to stop'),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator()),
          ],
        ));
      default:
        return Container();
    }
  }

  Widget _getActionButton(AppState state) {
    switch (state) {
      case AppState.initialising:
      case AppState.error:
        return const FloatingActionButton(
          backgroundColor: Colors.grey,
          onPressed: null,
        );
      case AppState.ready:
        return FloatingActionButton(
          onPressed: () {
            _record();
          },
          tooltip: "Record",
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: const Icon(Icons.radio_button_checked),
          ),
          elevation: 4.0,
        );
      case AppState.recording:
        return FloatingActionButton(
          onPressed: () {
            _stop();
          },
          tooltip: "Stop",
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: const Icon(Icons.stop),
          ),
          elevation: 4.0,
        );
      default:
        return Container();
    }
  }

  void _record() async {
    var _settings = VICallSettings();
    _settings.videoFlags = VIVideoFlags(sendVideo: true);
    _call = await _client.call("", settings: _settings);
    _call?.onCallConnected = _onCallConnected;
    _call?.onCallDisconnected = _onCallDisconneced;
    _call?.onMessageReceived = _onMessage;
  }

  void _stop() async {
    await _call?.hangup();
    _call = null;
  }

  void _onCallConnected(VICall call, Map<String, String>? headers) {
    setState(() {
      _state = AppState.recording;
    });
  }

  void _onMessage(VICall call, String message) {
    log(message);
  }

  void _onCallDisconneced(
      VICall call, Map<String, String>? headers, bool answeredElsewhere) {
    setState(() {
      _state = AppState.ready;
    });
  }
}
