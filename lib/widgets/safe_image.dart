import 'dart:async';
import 'package:flutter/material.dart';

class SafeImage extends StatefulWidget {
  const SafeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.showRetry = true,
    this.loadingWidget,
    this.errorWidget,
    this.timeout = const Duration(seconds: 10),
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final bool showRetry;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration timeout;

  @override
  State<SafeImage> createState() => _SafeImageState();
}

class _SafeImageState extends State<SafeImage> {
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SafeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeout, () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Image loading timeout';
        });
      }
    });

    try {
      final imageProvider = NetworkImage(widget.imageUrl);
      
      // Pre-load the image to check if it's valid
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          if (mounted) {
            _timeoutTimer?.cancel();
            setState(() {
              _imageProvider = imageProvider;
              _isLoading = false;
              _hasError = false;
            });
          }
          imageStream.removeListener(listener);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (exception, stackTrace) {
          if (mounted) {
            _timeoutTimer?.cancel();
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'Failed to load image';
            });
          }
          imageStream.removeListener(listener);
          if (!completer.isCompleted) {
            completer.completeError(exception);
          }
        },
      );

      imageStream.addListener(listener);
      await completer.future;
      
    } catch (e) {
      if (mounted) {
        _timeoutTimer?.cancel();
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = widget.loadingWidget ?? _buildDefaultLoadingWidget();
    } else if (_hasError) {
      content = widget.errorWidget ?? _buildDefaultErrorWidget();
    } else if (_imageProvider != null) {
      content = Image(
        image: _imageProvider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          // Handle runtime image errors
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Image display error';
              });
            }
          });
          return _buildDefaultErrorWidget();
        },
      );
    } else {
      content = _buildDefaultErrorWidget();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: content,
      ),
    );
  }

  Widget _buildDefaultLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Loading image...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Failed to load image',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showRetry) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadImage,
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 