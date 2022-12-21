import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PDFScreen extends StatefulWidget {
  final String? path;

  PDFScreen({Key? key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState(path);
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  PDFDocument? document;
  final String? path;

  _PDFScreenState(this.path);

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
      path!,
      cacheManager: CacheManager(
        Config(
          "customCacheKey",
          stalePeriod: const Duration(days: 2),
          maxNrOfCacheObjects: 10,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document!,
                lazyLoad: false,
                zoomSteps: 1,
              ),
      ),
    );
  }
}
