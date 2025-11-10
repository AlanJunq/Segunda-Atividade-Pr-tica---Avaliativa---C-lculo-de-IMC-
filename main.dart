import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

const kCorFundo = Colors.white;
const kCorTextoPrimaria = Colors.black;
const kCorCardAtivo = Color(0xFFB3E5FC);
const kCorCardInativo = Color(0xFFF5F5F5);
const kCorBotaoPrimario = Color(0xFF81D4FA);
const kCorBotaoInferior = Colors.blue;
const kCorTextoInativo = Color(0xFF616161);

const kEstiloTextoLabel = TextStyle(
  fontSize: 18.0,
  color: kCorTextoInativo,
  fontWeight: FontWeight.w500,
);

const kEstiloTextoNumero = TextStyle(
  fontSize: 48.0,
  fontWeight: FontWeight.w900,
  color: kCorTextoPrimaria,
);

const kEstiloBotaoGrande = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const kEstiloTextoCorpo = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
  color: kCorTextoPrimaria,
);

enum ViewState { input, result, info }
enum Gender { male, female }
enum InputField { weight, height }

void main() => runApp(const BMICalculatorApp());

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: kCorFundo,
        scaffoldBackgroundColor: kCorFundo,
        appBarTheme: const AppBarTheme(
          backgroundColor: kCorBotaoPrimario,
          elevation: 4,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  int _weight = 0;
  int _height = 0;
  InputField _currentInput = InputField.weight;

  ViewState _currentView = ViewState.input;

  Gender _selectedGender = Gender.male;

  double? _bmiResult;
  String _bmiCategory = "";

  String? _errorMessage;

  void _onNumberPressed(int number) {
    HapticFeedback.lightImpact();
    setState(() {
      int currentValue;
      int maxLimit;

      if (_currentInput == InputField.weight) {
        currentValue = _weight;
        maxLimit = 300;
      } else {
        currentValue = _height;
        maxLimit = 250;
      }

      int newValue;

      if (currentValue == 0) {
        newValue = number;
      } else {
        newValue = currentValue * 10 + number;
      }

      if (newValue <= maxLimit) {
        if (_currentInput == InputField.weight) {
          _weight = newValue;
        } else {
          _height = newValue;
        }
        _errorMessage = null;
      }
    });
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentInput == InputField.weight) {
        _weight = (_weight ~/ 10);
      } else {
        _height = (_height ~/ 10);
      }
      _errorMessage = null;
    });
  }

  void _calculateBmi() {
    HapticFeedback.lightImpact();

    final double weight = _weight.toDouble();
    final double height = _height.toDouble();

    if (weight < 10 || height < 100) {
      setState(() {
        _errorMessage = "Por favor, insira um Peso (min 10kg) e Altura (min 100cm/1.00m) válidos.";
      });
      return;
    }

    final double heightInMeters = height / 100.0;
    final double bmi = weight / (heightInMeters * heightInMeters);

    String category;
    if (bmi < 18.5) {
      category = "Abaixo do peso";
    } else if (bmi < 24.9) {
      category = "Normal";
    } else if (bmi < 29.9) {
      category = "Sobrepeso";
    } else {
      category = "Obesidade";
    }

    setState(() {
      _bmiResult = bmi;
      _bmiCategory = category;
      _currentView = ViewState.result;
    });
  }

  void _resetCalculator() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentView = ViewState.input;
      _bmiResult = null;
      _bmiCategory = "";
      _errorMessage = null;
    });
  }

  void _showInfoScreen() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentView = ViewState.info;
    });
  }

  void _backToInputScreen() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentView = ViewState.input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CALCULADORA DE IMC'),
        actions: _currentView == ViewState.input
            ? [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: kCorTextoPrimaria),
                  onPressed: _showInfoScreen,
                  tooltip: 'Categorias de IMC',
                ),
              ]
            : null,
        leading: _currentView != ViewState.input
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: kCorTextoPrimaria),
                onPressed: _currentView == ViewState.result ? _resetCalculator : _backToInputScreen,
                tooltip: 'Voltar',
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentView) {
      case ViewState.input:
        return _buildInputView();
      case ViewState.result:
        return _buildResultView();
      case ViewState.info:
        return _buildInfoView();
    }
  }

  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGenderCard(
                          gender: Gender.male,
                          label: 'MASCULINO',
                          icon: Icons.male,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderCard(
                          gender: Gender.female,
                          label: 'FEMININO',
                          icon: Icons.female,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildValueCard(
                        field: InputField.weight,
                        label: 'SEU PESO (kg)',
                        value: _weight,
                        unit: 'kg',
                        onTap: () => setState(() => _currentInput = InputField.weight),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildValueCard(
                        field: InputField.height,
                        label: 'SUA ALTURA (cm)',
                        value: _height,
                        unit: 'cm',
                        onTap: () => setState(() => _currentInput = InputField.height),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 10),
                _buildCustomNumericKeypad(),
              ],
            ),
          ),
        ),
        _buildBottomButton(
          onTap: _calculateBmi,
          label: 'CALCULAR SEU IMC',
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SEU RESULTADO',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kCorTextoPrimaria),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: kCorCardInativo,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _bmiCategory.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _bmiResult?.toStringAsFixed(1) ?? 'N/A',
                  style: kEstiloTextoNumero.copyWith(fontSize: 80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Um IMC entre 18.5 e 24.9 é considerado peso normal. Mantenha um estilo de vida saudável!',
                  style: kEstiloTextoLabel.copyWith(fontSize: 16, color: kCorTextoPrimaria),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildBottomButton(
            onTap: _resetCalculator,
            label: 'CALCULAR IMC NOVAMENTE',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Categorias de IMC',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kCorTextoPrimaria),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: kCorCardInativo,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow("Menos de 18.5", "Abaixo do peso", Colors.orange),
                const Divider(),
                _buildInfoRow("18.5 a 24.9", "Normal", const Color(0xFF00C853)),
                const Divider(),
                _buildInfoRow("25 a 29.9", "Sobrepeso", Colors.orange),
                const Divider(),
                _buildInfoRow("30 ou mais", "Obesidade", Colors.red),
              ],
            ),
          ),
          const Spacer(),
          _buildBottomButton(
            onTap: _backToInputScreen,
            label: 'VOLTAR PARA CÁLCULO',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({required VoidCallback onTap, required String label}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.0,
        decoration: BoxDecoration(
          color: kCorBotaoInferior,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Center(
          child: Text(label, style: kEstiloBotaoGrande),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required Gender gender,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedGender == gender;
    final Color cardColor = isSelected ? kCorCardAtivo : kCorCardInativo;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(50.0), 
          border: isSelected ? Border.all(color: kCorBotaoInferior, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: isSelected ? kCorBotaoInferior.withOpacity(0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: kCorTextoPrimaria),
            const SizedBox(height: 10),
            Text(
                label,
                style: kEstiloTextoLabel.copyWith(
                  color: kCorTextoPrimaria,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard({
    required InputField field,
    required String label,
    required int value,
    required String unit,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _currentInput == field;
    final Color cardColor = isSelected ? kCorCardAtivo : kCorCardInativo;

    String displayValue = value == 0 ? '--' : value.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          border: isSelected ? Border.all(color: kCorBotaoInferior, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: isSelected ? kCorBotaoInferior.withOpacity(0.3) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: kEstiloTextoLabel),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayValue,
                  style: kEstiloTextoNumero,
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: kEstiloTextoLabel.copyWith(fontSize: 24.0, fontWeight: FontWeight.bold, color: kCorTextoPrimaria),
                ),
              ],
            ),
            if (value == 0)
              Text('Toque p/ digitar', style: kEstiloTextoLabel.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNumericKeypad() {
    final List<List<int?>> keypadLayout = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [null, 0, -1],
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: keypadLayout.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return _buildKeypadButton(key);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(int? key) {
    if (key == null) {
      return const Expanded(child: SizedBox(height: 70));
    }

    VoidCallback onTap;
    Widget child;
    Color buttonColor;

    if (key == -1) {
      onTap = _onBackspacePressed;
      child = const Icon(Icons.backspace_outlined, size: 30, color: kCorTextoPrimaria);
      buttonColor = const Color(0xFFBDBDBD);
    } else {
      onTap = () => _onNumberPressed(key);
      child = Text(key.toString(), style: kEstiloTextoNumero.copyWith(fontSize: 30));
      buttonColor = const Color(0xFFFAFAFA);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String range, String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(range, style: kEstiloTextoLabel.copyWith(color: kCorTextoPrimaria, fontSize: 18)),
          Text(
            category,
            style: kEstiloTextoCorpo.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
