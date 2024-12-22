import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(PoseDetectionApp(cameras: cameras));
}

class PoseDetectionApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  PoseDetectionApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PoseDetectionScreen(cameras: cameras),
    );
  }
}

class PoseDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  PoseDetectionScreen({required this.cameras});

  @override
  _PoseDetectionScreenState createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  late CameraController _controller;
  late Interpreter _interpreter;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

Future<void> _initializeCamera() async {
  if (widget.cameras.isEmpty) {
    print("No cameras found!");
    return;
  }

  _controller = CameraController(
    widget.cameras.first,
    ResolutionPreset.medium,
  );

  try {
    await _controller.initialize();
    if (!mounted) return;

    setState(() {});
    _controller.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _runModel(image).then((_) {
          _isDetecting = false;
        });
      }
    });
  } catch (e) {
    print("Error initializing camera: $e");
  }
}


  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('models/pose_model.tflite');
  }

  Future<void> _runModel(CameraImage image) async {
    // Preprocesamiento de la imagen
    final input = _preprocess(image);

    // Ejecutar la inferencia
    final output = List.filled(1 * 17 * 3, 0.0).reshape([1, 17, 3]);
    _interpreter.run(input, output);

    // Procesar los resultados
    _processOutput(output.cast<List<List<double>>>());
  }

  List<List<List<double>>> _preprocess(CameraImage image) {
    // Convertir la imagen a formato adecuado y normalizar
    // Esta función debe adaptarse según el modelo y sus requisitos de entrada
    // Por ejemplo, cambiar el tamaño de la imagen a 192x192 y normalizar los valores de píxel
    // Aquí se proporciona una estructura básica que debes completar según tus necesidades
    // Asegúrate de que la imagen esté en el formato y tamaño que requiere tu modelo
    // Además, maneja la conversión de formatos de color si es necesario
    // Por ejemplo, si el modelo espera una imagen RGB, convierte la imagen de la cámara al formato adecuado
    // También considera la orientación de la imagen y ajústala si es necesario
    // Finalmente, convierte la imagen en una lista de listas de listas de valores de píxel normalizados
    // Esta es una implementación de ejemplo que debes adaptar:
    // return List.generate(192, (y) => List.generate(192, (x) => [0.0, 0.0, 0.0]));
    // Reemplaza la línea anterior con tu lógica de preprocesamiento
    throw UnimplementedError('Preprocesamiento de la imagen no implementado');
  }

  void _processOutput(List<List<List<double>>> output) {
    // Procesar la salida del modelo
    // Esta función debe adaptarse según el formato de salida de tu modelo
    // Por ejemplo, extraer las coordenadas de los puntos clave y sus puntuaciones
    // Aquí se proporciona una estructura básica que debes completar según tus necesidades
    // Asegúrate de interpretar correctamente la salida del modelo
    // Por ejemplo, si el modelo proporciona coordenadas normalizadas, conviértelas a coordenadas de píxel
    // También puedes filtrar los puntos clave según una puntuación mínima de confianza
    // Finalmente, actualiza el estado de la aplicación para reflejar los resultados de la detección
    // Esta es una implementación de ejemplo que debes adaptar:
    // setState(() {
    //   // Actualiza el estado con los resultados procesados
    // });
    // Reemplaza la lógica anterior con tu procesamiento de salida
    throw UnimplementedError('Procesamiento de la salida no implementado');
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pose Detection App'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Detection App'),
      ),
      body: Stack(
        children: [
          CameraPreview(_controller),
          // Aquí puedes añadir widgets para mostrar los resultados de la detección
        ],
      ),
    );
  }
}
