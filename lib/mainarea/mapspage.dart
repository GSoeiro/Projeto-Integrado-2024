import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleMapsPage extends StatefulWidget {
  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  late Future<LatLng> _localizacaoAtualFuturo;
  late Completer<GoogleMapController> _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = Completer();
    _localizacaoAtualFuturo = _handleLocationPermission();
  }

  Future<LatLng> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await _getLocalizacaoAtual();
  }

  Future<LatLng> _getLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _saveCoordinates(LatLng coordinates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('selected_latitude', coordinates.latitude);
    await prefs.setDouble('selected_longitude', coordinates.longitude);
  }

  Future<void> _onMapTapped(LatLng tappedLatLng) async {
    await _saveCoordinates(tappedLatLng);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Coordenadas salvas: ${tappedLatLng.latitude}, ${tappedLatLng.longitude}'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização'),
      ),
      body: FutureBuilder<LatLng>(
        future: _localizacaoAtualFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao obter localização'));
          } else if (snapshot.hasData) {
            LatLng currentLocation = snapshot.data!;
            double lat = currentLocation.latitude;
            double long = currentLocation.longitude;

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, long),
                zoom: 11.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('Ponto Escolhido'),
                  position: LatLng(lat, long),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: _onMapTapped, // Captura o evento de toque no mapa
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            );
          } else {
            return const Center(child: Text('Sem localização disponível'));
          }
        },
      ),
    );
  }
}
