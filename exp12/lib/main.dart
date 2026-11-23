
import 'dart:async';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeviceUtilityApp());
}

class DeviceUtilityApp extends StatelessWidget {
  const DeviceUtilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Device Utility',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  File? profileImage;

  StreamSubscription<AccelerometerEvent>? sensorSubscription;

  double x = 0;
  double y = 0;
  double z = 0;

  double acceleration = 0;
  Position? currentPosition;

  bool isLoadingLocation = false;
  bool isShaking = false;

  DateTime lastShakeTime =
      DateTime.fromMillisecondsSinceEpoch(0);

  // CAMERA
  Future<void> captureImage() async {
    final permission = await Permission.camera.request();

    if (!permission.isGranted) {
      showMessage('Camera permission denied. Please allow access.');
      return;
    }

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      showMessage('Unable to capture image: $e');
    }
  }

  // GALLERY
  Future<void> selectImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      showMessage('Unable to select image: $e');
    }
  }

  // UPDATE PROFILE PHOTO
  void updateProfilePhoto() {
    if (selectedImage == null) {
      showMessage('Please capture or select an image first.');
      return;
    }

    setState(() {
      profileImage = selectedImage;
    });

    showMessage('Profile photo updated successfully!');
  }

  // ACCELEROMETER
  void startSensors() {
    sensorSubscription?.cancel();

    sensorSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen(
      (event) {
        final magnitude = math.sqrt(
          event.x * event.x +
              event.y * event.y +
              event.z * event.z,
        );

        if (!mounted) return;

        setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
          acceleration = magnitude;
        });

        detectShake(magnitude);
      },
      onError: (error) {
        showMessage('Sensor error: $error');
      },
    );
  }

  // SHAKE DETECTION
  void detectShake(double magnitude) {
    const double shakeThreshold = 25.0;

    final now = DateTime.now();

    if (magnitude > shakeThreshold &&
        now.difference(lastShakeTime).inMilliseconds > 1500) {
      lastShakeTime = now;

      if (!mounted) return;

      setState(() {
        isShaking = true;
      });

      showMessage('Device shaken! Shake detected.');

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isShaking = false;
          });
        }
      });
    }
  }

  // GPS LOCATION
  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMessage('Please enable GPS/location services.');
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        showMessage('Location permission denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        showMessage(
          'Location permission permanently denied. Enable it in Settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
      });

      showMessage('Location obtained successfully!');
    } catch (e) {
      showMessage('Unable to get location: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
        });
      }
    }
  }

  // CLEAR IMAGE
  void removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  // SNACKBAR
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // SECTION CARD
  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startSensors();
  }

  @override
  void dispose() {
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mobile Device Utility',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // PROFILE PHOTO
            sectionCard(
              title: 'Profile Photo',
              icon: Icons.account_circle,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.deepPurple,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Your Profile Picture'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: updateProfilePhoto,
                    icon: const Icon(Icons.upload),
                    label: const Text('Update Profile Photo'),
                  ),
                ],
              ),
            ),

            // CAMERA AND GALLERY
            sectionCard(
              title: 'Camera & Gallery',
              icon: Icons.camera_alt,
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 65,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text('No image selected'),
                            ],
                          ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: captureImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: selectImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: selectedImage == null
                              ? null
                              : updateProfilePhoto,
                          icon: const Icon(Icons.person),
                          label: const Text('Set as Profile'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: selectedImage == null
                              ? null
                              : removeImage,
                          icon: const Icon(Icons.delete),
                          label: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SENSOR DATA
            sectionCard(
              title: 'Accelerometer Sensor',
              icon: Icons.sensors,
              child: Column(
                children: [
                  sensorTile('X Axis', x),
                  sensorTile('Y Axis', y),
                  sensorTile('Z Axis', z),
                  const Divider(),
                  sensorTile('Total Acceleration', acceleration),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isShaking
                          ? Colors.orange.shade100
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isShaking
                              ? Icons.vibration
                              : Icons.check_circle,
                          color: isShaking
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isShaking
                                ? 'Shake detected!'
                                : 'Waiting for device movement...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // GPS LOCATION
            sectionCard(
              title: 'GPS Location',
              icon: Icons.location_on,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentPosition == null)
                    const Text(
                      'Location not obtained yet.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else ...[
                    locationTile(
                      'Latitude',
                      currentPosition!.latitude.toStringAsFixed(6),
                    ),
                    locationTile(
                      'Longitude',
                      currentPosition!.longitude.toStringAsFixed(6),
                    ),
                    locationTile(
                      'Accuracy',
                      '${currentPosition!.accuracy.toStringAsFixed(2)} metres',
                    ),
                    locationTile(
                      'Altitude',
                      '${currentPosition!.altitude.toStringAsFixed(2)} metres',
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingLocation
                          ? null
                          : getCurrentLocation,
                      icon: isLoadingLocation
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        isLoadingLocation
                            ? 'Getting Location...'
                            : 'Get Current Location',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Mobile Device Utility App • Flutter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget sensorTile(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toStringAsFixed(3),
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget locationTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
