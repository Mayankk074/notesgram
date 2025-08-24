import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class CachedPdfViewer extends StatefulWidget {
  final String pdfUrl;
  const CachedPdfViewer({super.key, required this.pdfUrl});

  @override
  State<CachedPdfViewer> createState() => _CachedPdfViewerState();
}

class _CachedPdfViewerState extends State<CachedPdfViewer> {
  File? _cachedFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Try to get file from cache (or download if not cached)
      final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);
      setState(() {
        _cachedFile = file;
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading PDF: $e");
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cachedFile == null) {
      return const Center(child: Text("Failed to load PDF"));
    }

    return SfPdfViewer.file(_cachedFile!);
  }
}
