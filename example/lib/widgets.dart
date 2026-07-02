
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Displays a Widget with a color, label and value.
class ValueBox extends StatelessWidget {
  final Color color;

  final String label;

  final String value;

  const ValueBox({
    this.label = "",
    this.value = "",
    this.color = Colors.grey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a Alert Dialog to edit the site ID
class SiteIDDialog extends StatefulWidget {
  final int? siteID;

  const SiteIDDialog({this.siteID, super.key});

  @override
  State<StatefulWidget> createState() => _SiteIDDialogState();
}

class _SiteIDDialogState extends State<SiteIDDialog> {
  int? siteID;

  @override
  void initState() {
    siteID = widget.siteID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color.fromRGBO(255, 153, 26, 1);
    return AlertDialog(
      title: Text("Set Site ID"),
      content: SingleChildScrollView(
        child: TextFormField(
          initialValue: siteID?.toRadixString(16) ?? '',
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-fA-F0-9]')),
          ],
          cursorColor: color,
          decoration: InputDecoration(
            prefixText: '0x',
            labelStyle: TextStyle(color: color),
            labelText: "SiteID: ",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: color,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value, radix: 16);
            siteID = parsed;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(siteID);
          },
          child: Text(
            "Set",
            style: TextStyle(color: color),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}

/// Displays a Alert Dialog to select a .bin file
class BinFileDialog extends StatefulWidget {
  final String? fileName;

  const BinFileDialog({this.fileName, super.key});

  @override
  State<StatefulWidget> createState() => _BinFileDialogState();
}

class _BinFileDialogState extends State<BinFileDialog> {
  String? fileName;

  FilePickerResult? filePickerResult;

  late String message;

  @override
  void initState() {
    fileName = widget.fileName;
     message = fileName == null ? 'Please upload a bin file for positioning!' : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Upload bin file"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(fileName ?? 'No file selected!'),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final binFileResult = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    allowMultiple: false,
                  );
                  if (binFileResult != null && binFileResult.files.isNotEmpty) {
                    final path = binFileResult.files.single.path;

                    if (path != null) {
                      if (!path.endsWith('.bin')) {
                        setState(() {
                          message = 'Wrong file type. Please select a .bin file.';
                        });
                      } else {
                        setState(() {
                          fileName = binFileResult.files.single.name;
                          filePickerResult = binFileResult;
                          message = '';
                        });
                      }

                    }
                  }
                },
                icon: Icon(Icons.upload_file_outlined),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(filePickerResult);
          },
          child: Text(
            "Set",
            style: TextStyle(color: Color.fromRGBO(255, 153, 26, 1)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Color.fromRGBO(255, 153, 26, 1)),
          ),
        ),
      ],
    );
  }
}
