import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PrescriptionOcrPage extends StatefulWidget {
  const PrescriptionOcrPage({Key? key}) : super(key: key);
  static const routeName = 'chat page';


  @override
  _PrescriptionOcrPageState createState() => _PrescriptionOcrPageState();
}

class _PrescriptionOcrPageState extends State<PrescriptionOcrPage> {
  File? _image;
  String _extractedText = '';
  List<Map<String, dynamic>> _boundingBoxes = [];
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  String _errorMessage = '';

  final ImagePicker _picker = ImagePicker();
  final String _apiKey = 'OGHAaEG8LXNoAewlO7t7rg==7kyhVv6hftG6NSIf';
  final String _apiUrl = 'https://api.api-ninjas.com/v1/imagetotext';
  final int _maxImageSize = 200 * 1024; // 200KB in bytes

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _extractedText = '';
        _boundingBoxes = [];
        _textController.clear();
        _isLoading = false;
        _errorMessage = '';
      });
      _compressAndExtractText();
    }
  }

  // Compress image to under 200KB and extract text
  Future<void> _compressAndExtractText() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Verify original image
      if (!await _image!.exists()) {
        throw Exception('Image file does not exist: ${_image!.path}');
      }
      var originalSize = await _image!.length();
      print('DEBUG: Original image path: ${_image!.path}, size: $originalSize bytes');

      // Validate image format (JPEG, PNG, GIF, BMP)
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
      final extension = _image!.path.toLowerCase();
      if (!validExtensions.any((ext) => extension.endsWith(ext))) {
        throw Exception('Unsupported image format. Use JPEG, PNG, GIF, or BMP.');
      }

      // Compress image if necessary
      File compressedImage = _image!;
      if (originalSize > _maxImageSize) {
        print('DEBUG: Compressing image to under 200KB');
        final image = img.decodeImage(await _image!.readAsBytes())!;

        // Resize image while maintaining aspect ratio
        const maxDimension = 800; // Reduce resolution
        double scale = 1.0;
        if (image.width > maxDimension || image.height > maxDimension) {
          scale = maxDimension / (image.width > image.height ? image.width : image.height);
        }
        final resized = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
        );

        // Compress as JPEG with decreasing quality until under 200KB
        int quality = 90;
        List<int> encoded;
        do {
          encoded = img.encodeJpg(resized, quality: quality);
          quality -= 10;
          if (quality < 10) break;
        } while (encoded.length > _maxImageSize);

        if (encoded.length > _maxImageSize) {
          throw Exception('Could not compress image to under 200KB. Try a smaller image.');
        }

        // Save compressed image
        final tempDir = await getTemporaryDirectory();
        compressedImage = File('${tempDir.path}/compressed_image.jpg')
          ..writeAsBytesSync(encoded);
        final compressedSize = await compressedImage.length();
        print('DEBUG: Compressed image size: $compressedSize bytes');
      }

      // Send compressed image to API
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.headers['X-Api-Key'] = _apiKey;
      request.files.add(await http.MultipartFile.fromPath('image', compressedImage.path));
      print('DEBUG: Sending request to $_apiUrl with API key');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('DEBUG: API response status: ${response.statusCode}, body: $responseBody');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(responseBody);
        final List<Map<String, dynamic>> boundingBoxes = jsonResponse.map((item) {
          return {
            'text': item['text'] as String,
            'bounding_box': {
              'x1': (item['bounding_box']['x1'] as num).toDouble(),
              'y1': (item['bounding_box']['y1'] as num).toDouble(),
              'x2': (item['bounding_box']['x2'] as num).toDouble(),
              'y2': (item['bounding_box']['y2'] as num).toDouble(),
            },
          };
        }).toList();

        final fullText = jsonResponse.map((item) => item['text'] as String).join('\n');

        setState(() {
          _boundingBoxes = boundingBoxes;
          _extractedText = fullText.isEmpty ? 'No text detected' : fullText;
          _textController.text = _extractedText;
          _isLoading = false;
        });
      } else {
        setState(() {
          _extractedText = 'Error: API returned status ${response.statusCode}: $responseBody';
          _textController.text = _extractedText;
          _boundingBoxes = [];
          _isLoading = false;
          _errorMessage = 'API request failed: $responseBody';
        });
      }
    } catch (e) {
      print('ERROR: Failed to extract text: $e');
      setState(() {
        _extractedText = 'Error extracting text: $e';
        _textController.text = _extractedText;
        _boundingBoxes = [];
        _isLoading = false;
        _errorMessage = 'Failed to process image: $e';
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription OCR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Prescription Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Camera'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty) ...[
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 10),
            ],
            if (_image != null) ...[
              Stack(
                children: [
                  Image.file(
                    _image!,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  CustomPaint(
                    painter: BoundingBoxPainter(
                      boundingBoxes: _boundingBoxes,
                      imageFile: _image!,
                    ),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            const Text(
              'Extracted Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 5,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _textController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text copied to clipboard')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Disclaimer: OCR results are for demonstration only. Consult a pharmacist for accurate prescription details.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw low-opacity rectangles around text
class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;
  final File imageFile;

  BoundingBoxPainter({required this.boundingBoxes, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Get image dimensions
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Calculate scaling factors to fit image in display
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    for (var box in boundingBoxes) {
      final rect = box['bounding_box'];
      final scaledRect = Rect.fromLTRB(
        rect['x1'] * scale,
        rect['y1'] * scale,
        rect['x2'] * scale,
        rect['y2'] * scale,
      );
      canvas.drawRect(scaledRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}