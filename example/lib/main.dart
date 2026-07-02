import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinpoint_sdk/pinpoint_sdk.dart';
import 'package:pinpoint_sdk_example/widgets.dart';
import 'package:file_picker/file_picker.dart';

import 'package:logging/logging.dart';

Future<void> main() async {
  hierarchicalLoggingEnabled = true;
  // listen only to logs by the Pinpoint SDK
  Logger('pinpoint_sdk').onRecord.listen((record) {
    print('${record.time} [${record.loggerName}] ${record.message}');
  });

  runApp(MaterialApp(home: Example()));
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  /// Position stream that tracks the current location updates.
  Stream<Position>? _positioningStream;

  /// Determines if the [_positioningStream] is null.
  bool get _isPositioning => _positioningStream != null;

  /// Selected Bin File that will be send to the tracelet
  Uint8List? _selectedBinFile;

  /// Name of the Bin File
  String? _fileName;

  /// Manually optional selected Site ID. Must be inside of the bin file.
  int? _siteID;

  /// Messages from the service status stream and app status.
  final List<String> _messages = [];

  /// Current service status.
  ServiceStatus? _serviceStatus;

  /// Future of initializing Geolocator
  late final Future<void> _initGeolocator;

  @override
  void initState() {
    super.initState();
    _initGeolocator = initGeolocator();
  }

  /// Initializes the Geolocator with an api key
  Future<void> initGeolocator() async {

    late final String licenseKey;
    try {
      // First create `api_key.txt` and insert your API key there
      licenseKey = await rootBundle.loadString('assets/api_key.txt');

    } catch (error) {
      _messages.add(
        'Loading API key failed.',
      );
      return;
    }

    return Geolocator.initialize(
      licenseKey: licenseKey,
      onTokenExpired: () {
        _stopPositioning();
        setState(() {
          _messages.add('Token expired! Turn on your internet');
        });
      },
      onTokenExpiring: (seconds) {
        setState(() {
          _messages.add(
            'Token expiring in ${Duration(seconds: seconds)}. Turn on your internet!',
          );
        });
      },
    )
    .onError((error, stack) {
      setState(() {
        _messages.add(
          'Initializing Geolocator with license key failed \n because of: $error',
        );
      });
    })
    .whenComplete(() {
      _initServiceStream();
      setState(() {
        _messages.add(
          'Please import a .bin file and set a siteID before positioning!',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color.fromRGBO(255, 153, 26, 1);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Pin-Round-Orange@128px.png', height: 32),
            const SizedBox(width: 10),
            const Text("Pinpoint Flutter SDK Example"),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: FutureBuilder(
        future: _initGeolocator,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.done) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    if (!asyncSnapshot.hasError)
                      StreamBuilder(
                        stream: _positioningStream,
                        builder: (context, snapshot) {
                          bool hasPosition = snapshot.hasData;
                          bool isIndoorPosition =
                              snapshot.data is IndoorPosition;

                          // Received position when the position stream is running. Can be a outdoor or indoor position.
                          Position? position = snapshot.data;

                          return Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Text(
                                    "WGS84 Coordinates",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_isPositioning && !hasPosition)
                                    CircularProgressIndicator(color: mainColor),
                                  MenuAnchor(
                                    menuChildren: [
                                      TextButton(
                                        onPressed: () async {
                                          await _selectBinFile();
                                        },
                                        child: Text(
                                          'Upload bin file',
                                          style: TextStyle(color: mainColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _setSiteID();
                                        },
                                        child: Text(
                                          'Set site ID',
                                          style: TextStyle(color: mainColor),
                                        ),
                                      ),
                                    ],
                                    builder: (context, controller, child) {
                                      return IconButton(
                                        onPressed: controller.isOpen
                                            ? controller.close
                                            : controller.open,
                                        icon: Icon(Icons.settings),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (_isPositioning)
                                Row(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      isIndoorPosition
                                          ? "indoor position"
                                          : "outdoor position",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: isIndoorPosition
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ValueBox(
                                label: "Latitude",
                                value: _isPositioning && hasPosition
                                    ? position!.latitude.toString()
                                    : "",
                                color: Colors.red.shade300,
                              ),
                              ValueBox(
                                label: "Longitude",
                                value: _isPositioning && hasPosition
                                    ? position!.longitude.toString()
                                    : "",
                                color: Colors.green.shade300,
                              ),
                              ValueBox(
                                label: "Accuracy",
                                value: _isPositioning && hasPosition
                                    ? "${position!.accuracy.toStringAsFixed(2)} m"
                                    : "",
                                color: Colors.blue.shade300,
                              ),
                              Text(
                                "For positioning please hold your TRACElet close to the device.",
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isPositioning
                                      ? _stopPositioning
                                      : _startPositioning,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPositioning
                                        ? Colors.red
                                        : Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _isPositioning
                                        ? "Stop Positioning"
                                        : "Start Positioning",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    Container(
                      height: 200,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Text(_messages[_messages.length - 1 - index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(color: mainColor));
          }
        },
      ),
    );
  }

  /// Initializes the service stream to get updates on bluetooth, location and TRACElet service.
  void _initServiceStream() {
    final serviceStatusStream = Geolocator.getServiceStatusStream();
    serviceStatusStream
        .handleError((dynamic error) {
          setState(() {
            _messages.add('Error in service stream: $error');
          });
        })
        .listen((serviceStatus) async {
          String? service;
          String? serviceStatusValue;
          if (_serviceStatus == null) {
            setState(() {
              _messages.add(serviceStatus.toString());
              _serviceStatus = serviceStatus;
            });
          } else if (serviceStatus.bluetoothEnabled !=
                  _serviceStatus!.bluetoothEnabled &&
              serviceStatus.bluetoothEnabled != null) {
            service = 'Bluetooth';
            serviceStatusValue = serviceStatus.bluetoothEnabled!
                ? 'enabled'
                : 'disabled';
          } else if (serviceStatus.locationEnabled !=
                  _serviceStatus!.locationEnabled &&
              serviceStatus.locationEnabled != null) {
            service = 'Location service';
            serviceStatusValue = serviceStatus.locationEnabled!
                ? 'enabled'
                : 'disabled';
          } else if (serviceStatus.traceletConnected !=
                  _serviceStatus!.traceletConnected &&
              serviceStatus.traceletConnected != null) {
            service = 'TRACElet';
            serviceStatusValue = serviceStatus.traceletConnected!
                ? 'connected'
                : 'disconnected';
          } else if (serviceStatus.uwbEnabled !=
                  _serviceStatus!.uwbEnabled &&
              serviceStatus.uwbEnabled != null) {
            service = 'UWB';
            serviceStatusValue = serviceStatus.uwbEnabled!
                ? 'enabled'
                : 'disabled';
          }

          if (service != null && serviceStatusValue != null) {
            setState(() {
              _messages.add('$service has been $serviceStatusValue.');
              _serviceStatus = serviceStatus;
            });
          }
          // Do not cancel the subscription because the stream continues if the services are enabled again.
        });
  }

  ///Requests location and bluetooth Permission and checks if the permission was granted.
  Future<bool> _checkPermissions() async {
    var locationPermission = await Geolocator.checkLocationPermission();
    var bluetoothPermission = await Geolocator.checkIndoorPermission();

    if (locationPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }

    if (bluetoothPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }

    if (locationPermission != LocationPermission.always &&
        locationPermission != LocationPermission.whileInUse) {
      locationPermission = await Geolocator.requestLocationPermission();
    }
    if ((bluetoothPermission != LocationPermission.always &&
        bluetoothPermission != LocationPermission.whileInUse)) {
      bluetoothPermission = await Geolocator.requestIndoorPermission();
    }

    if ((locationPermission != LocationPermission.always &&
            locationPermission != LocationPermission.whileInUse) ||
        (bluetoothPermission != LocationPermission.always &&
            bluetoothPermission != LocationPermission.whileInUse)) {
      return false;
    }
    return true;
  }

  /// Select a bin File. Opens a filePicker dialog.
  Future<void> _selectBinFile() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return BinFileDialog(fileName: _fileName);
      },
    );

    if (result != null && result is FilePickerResult) {
      _fileName = result.files.single.name;
      if (result.files.single.path != null) {
        _selectedBinFile = File(result.files.single.path!).readAsBytesSync();
      }
    }
  }

  /// Set site ID.
  Future<void> _setSiteID() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SiteIDDialog(siteID: _siteID);
      },
    );

    if (result != null) {
      setState(() {
        _siteID = result;
      });
    }
  }

  /// Cancels the positioning stream.
  void _stopPositioning() async {
    setState(() {
      _positioningStream = null;
      _messages.add('Stop Positioning');
    });
  }

  /// Starts the positioning stream
  /// if a bin file and siteID are selected and [_checkPermissions] is true.
  Future<void> _startPositioning() async {
    try {
      if (!await _checkPermissions()) return;

      if (_selectedBinFile == null) {
        await _selectBinFile();
        if(_selectedBinFile == null) {
          return;
        }
      }

      if (_siteID == null) {
        await _setSiteID();
        if(_siteID == null) return;
      }

      setState(() {
        _positioningStream =
            Geolocator.getPositionStream(
              siteId: _siteID!,
              binFile: _selectedBinFile!,
              locationSettings: const LocationSettings(
                distanceFilter: 0,
                timeLimit: Duration(minutes: 1),
              ),
            ).handleError((e) {
              setState(() {
                _messages.add(e.message);
                _stopPositioning();
              });
            });
        _messages.add('Start Positioning');
      });
    } catch (e) {
      setState(() {
        _messages.add(e.toString());
      });
    }
  }
}
