import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'blocs.dart';
import 'models.dart';

class QrCameraScreen extends StatelessWidget {
  final String? haUrl;
  QrCameraScreen({super.key, this.haUrl});
  final controller = MobileScannerController(returnImage: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        fit: BoxFit.contain,
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            BlocProvider.of<HAConnectionBloc>(context)
                .add(TokenFound(haUrl!, barcode.rawValue ?? ''));
            controller.stop();
            context.goNamed('home');
          }
        },
      ),
    );
  }
}
