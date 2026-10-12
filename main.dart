import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SoundToBinaryApp());
}

class SoundToBinaryApp extends StatelessWidget {
  const SoundToBinaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound-to-Binary Converter',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF1E293B),
        ),
      ),
      home: const ConverterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _freqController = TextEditingController(
    text: '1000',
  );
  final TextEditingController _ampController = TextEditingController(text: '1');
  final TextEditingController _samplesController = TextEditingController(
    text: '4',
  );
  final TextEditingController _bitsController = TextEditingController(
    text: '2',
  );

  double _freq = 1000;
  double _amp = 1;
  int _samples = 4;
  int _bits = 2;

  String _periodStr = '-';
  String _wavelengthStr = '-';
  String _binaryString = 'Click "Convert" to generate binary.';
  int _totalBits = 0;
  List<SampleRow> _sampleRows = [];

  @override
  void initState() {
    super.initState();
    _calculateWave();
  }

  String _padBinary(int num, int bits) {
    String bin = num.toRadixString(2);
    while (bin.length < bits) {
      bin = '0$bin';
    }
    return bin;
  }

  void _calculateWave() {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() {
      _freq = double.parse(_freqController.text);
      _amp = double.parse(_ampController.text);
      _samples = int.parse(_samplesController.text);
      _bits = int.parse(_bitsController.text);

      double periodMs = (1 / _freq) * 1000;
      _periodStr = '${periodMs.toStringAsFixed(2)} ms';

      double wavelengthM = 343 / _freq;
      if (wavelengthM >= 1) {
        _wavelengthStr = '${wavelengthM.toStringAsFixed(2)} m';
      } else {
        _wavelengthStr = '${(wavelengthM * 100).toStringAsFixed(1)} cm';
      }

      int levels = math.pow(2, _bits).toInt();
      List<SampleRow> rows = [];
      List<String> binArray = [];

      for (int i = 0; i < _samples; i++) {
        double timeMs = (i * periodMs) / _samples;
        double height = _amp * math.sin(2 * math.pi * i / _samples);

        double rawLevel = ((height + 1) / 2) * (levels - 1);
        int level = rawLevel.round();
        if (level < 0) level = 0;
        if (level >= levels) level = levels - 1;

        String binVal = _padBinary(level, _bits);
        binArray.add(binVal);

        rows.add(
          SampleRow(
            sampleNum: i + 1,
            time: timeMs.toStringAsFixed(2),
            amplitude: height.toStringAsFixed(2),
            level: level,
            binary: binVal,
          ),
        );
      }

      _sampleRows = rows;
      _totalBits = _samples * _bits;
      _binaryString = binArray.join(' ');
    });
  }

  WaveCalculatedResult _computeTestData(double f, double a, int s, int b) {
    double periodMs = (1 / f) * 1000;
    double wavelengthM = 343 / f;
    String wlStr = wavelengthM >= 1
        ? '${wavelengthM.toStringAsFixed(2)} m'
        : '${(wavelengthM * 100).toStringAsFixed(1)} cm';

    int levels = math.pow(2, b).toInt();
    List<String> binArray = [];
    for (int i = 0; i < s; i++) {
      double height = a * math.sin(2 * math.pi * i / s);
      double rawLevel = ((height + 1) / 2) * (levels - 1);
      int level = rawLevel.round().clamp(0, levels - 1);
      binArray.add(_padBinary(level, b));
    }
    return WaveCalculatedResult(
      period: '${periodMs.toStringAsFixed(2)} ms',
      wavelength: wlStr,
      totalBits: s * b,
      binaryString: binArray.join(' '),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound-to-Binary Converter'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.1),
                      border: const Border(
                        left: BorderSide(color: Color(0xFF38BDF8), width: 4),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Name: [Jerrson P. Torres]',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Section: BSCS-3'),
                        Text('Course: Multimedia (Asynchronous Activity)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _buildInputField('Frequency (Hz)', _freqController, (
                            val,
                          ) {
                            double? v = double.tryParse(val ?? '');
                            if (v == null || v <= 0) return 'Must be > 0';
                            return null;
                          }),
                          _buildInputField(
                            'Amplitude (0 to 1)',
                            _ampController,
                            (val) {
                              double? v = double.tryParse(val ?? '');
                              if (v == null || v < 0 || v > 1)
                                return 'Must be 0 to 1';
                              return null;
                            },
                          ),
                          _buildInputField(
                            'Number of Samples (2-64)',
                            _samplesController,
                            (val) {
                              int? v = int.tryParse(val ?? '');
                              if (v == null || v < 2 || v > 64)
                                return 'Must be 2 to 64';
                              return null;
                            },
                          ),
                          _buildInputField(
                            'Bits per Sample (1-8)',
                            _bitsController,
                            (val) {
                              int? v = int.tryParse(val ?? '');
                              if (v == null || v < 1 || v > 8)
                                return 'Must be 1 to 8';
                              return null;
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Convert Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: _calculateWave,
                    child: const Text(
                      'Convert',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Wave Facts
                  const Text(
                    'Wave Facts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 600
                        ? 4
                        : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildFactCard('Amplitude', '$_amp'),
                      _buildFactCard('Frequency', '$_freq Hz'),
                      _buildFactCard('Period', _periodStr),
                      _buildFactCard('Wavelength', _wavelengthStr),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sample Measurements
                  const Text(
                    'Sample Measurements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Sample #')),
                        DataColumn(label: Text('Time (ms)')),
                        DataColumn(label: Text('Amplitude')),
                        DataColumn(label: Text('Level')),
                        DataColumn(label: Text('Binary')),
                      ],
                      rows: _sampleRows.map((row) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${row.sampleNum}')),
                            DataCell(Text(row.time)),
                            DataCell(Text(row.amplitude)),
                            DataCell(Text('${row.level}')),
                            DataCell(Text(row.binary)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Binary Result
                  const Text(
                    'Full Binary Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      _binaryString,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF38BDF8),
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total Bits: $_totalBits',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // Test Results Section
                  const Text(
                    'Test Results Table',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Test')),
                        DataColumn(label: Text('Frequency')),
                        DataColumn(label: Text('Amplitude')),
                        DataColumn(label: Text('Samples')),
                        DataColumn(label: Text('Bits')),
                        DataColumn(label: Text('Period')),
                        DataColumn(label: Text('Wavelength')),
                        DataColumn(label: Text('Total bits')),
                        DataColumn(label: Text('Binary result')),
                      ],
                      rows: [
                        _buildTestRow('Test A', 440, 0.8, 8, 3),
                        _buildTestRow('Test B', 200, 0.5, 6, 4),
                        _buildTestRow('Test C', 500, 0.9, 5, 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Explain It Section
                  const Text(
                    'Explain It',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildExplainItem(
                    '1. In your own words, how does your app change a sound wave into binary? Name the three steps.',
                    'Sample the wave\'s height at equal time steps, round each height to the nearest level, then write each level in binary.',
                  ),
                  _buildExplainItem(
                    '2. Run Test A again with 2 bits, then 6 bits. Which gives more detail about the wave, and why?',
                    '6 bits gives more detail because it provides 64 levels instead of 4, allowing the binary representation to follow the wave\'s height much more closely, though it uses more bits.',
                  ),
                  _buildExplainItem(
                    '3. Which test has the longest wavelength? How is wavelength connected to frequency?',
                    'Test B (200 Hz) has the longest wavelength. Wavelength is inversely connected to frequency; a higher frequency means a shorter wavelength.',
                  ),
                  _buildExplainItem(
                    '4. What was the hardest stage to build, and how did you fix it?',
                    'Managing correct rounding of halfway sample heights and ensuring precise leading zeros for binary strings was challenging, which was resolved by implementing strict rounding functions and zero-padding logic.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    return SizedBox(
      width: 210,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        validator: validator,
        onChanged: (_) => _calculateWave(),
      ),
    );
  }

  Widget _buildFactCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTestRow(String testName, double f, double a, int s, int b) {
    WaveCalculatedResult res = _computeTestData(f, a, s, b);
    return DataRow(
      cells: [
        DataCell(Text(testName)),
        DataCell(Text('$f Hz')),
        DataCell(Text('$a')),
        DataCell(Text('$s')),
        DataCell(Text('$b')),
        DataCell(Text(res.period)),
        DataCell(Text(res.wavelength)),
        DataCell(Text('${res.totalBits}')),
        DataCell(
          Text(
            res.binaryString,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildExplainItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class SampleRow {
  final int sampleNum;
  final String time;
  final String amplitude;
  final int level;
  final String binary;

  SampleRow({
    required this.sampleNum,
    required this.time,
    required this.amplitude,
    required this.level,
    required this.binary,
  });
}

class WaveCalculatedResult {
  final String period;
  final String wavelength;
  final int totalBits;
  final String binaryString;

  WaveCalculatedResult({
    required this.period,
    required this.wavelength,
    required this.totalBits,
    required this.binaryString,
  });
}
