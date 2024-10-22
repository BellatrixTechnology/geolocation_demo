import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController _mapController;

  LatLng pos = const LatLng(12.383086, 123.441170);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.383086, 123.441170),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    getPermission();
    _markers.add(
      Marker(
        markerId: const MarkerId('marker_1'),
        position: pos,
      ),
    );
  }

  addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_1'),
          position: pos,
        ),
      );
    });
  }

  Future<Position?> determinePosition() async {
    // try {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print("permission $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    // } else {
    //   throw Exception('Error');
    // }

    return await Geolocator.getCurrentPosition();
    // } catch (e) {
    //   print("error is $e");
    //   return null;
    // }
  }

  getPermission() async {
    Position? v = await determinePosition();
    print("v is $v");
    if (v != null) {
      setState(() {
        pos = LatLng(v.latitude, v.longitude);
        _markers.clear(); // Clear existing markers
        _markers.add(
          Marker(
            markerId: MarkerId('marker_1'),
            position: pos,
          ),
        );
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLng(pos),
      );
    }
    // Geolocator.getCurrentPosition().then((v) {
    //   setState(() {
    //     pos = LatLng(v.latitude, v.longitude);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _mapController = controller;
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }
}
