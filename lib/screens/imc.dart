import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IMCCalculator extends StatefulWidget {
  const IMCCalculator({super.key});

  @override
  _IMCCalculatorState createState() => _IMCCalculatorState();
}

class _IMCCalculatorState extends State<IMCCalculator> {
  final TextEditingController _weightController = TextEditingController(text: "");
  final TextEditingController _heightController = TextEditingController(text: "");
  final TextEditingController _ageController = TextEditingController(text: "");
  String _sex = '';
  double _imc = 0.0;
  String _imcResult = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Exemple: 50'
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura (m)',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sexo: '),
                  Radio(
                    value: 'Male',
                    groupValue: _sex,
                    onChanged: (value) {
                      setState(() {
                        _sex = value!;
                      });
                    },
                  ),
                  const Text('Masculino'),
                  Radio(
                    value: 'Female',
                    groupValue: _sex,
                    onChanged: (value) {
                      setState(() {
                        _sex = value!;
                      });
                    },
                  ),
                  const Text('Feminino'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    _calculateIMC();
                    _saveData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, preencha todos os campos!'),
                      ),
                    );
                  }
                },
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),
              Text(
                'Seu IMC: $_imcResult',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Último IMC: $_imc',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    return _weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _sex.isNotEmpty;
  }

  void _calculateIMC() {
    double weight = double.parse(_weightController.text);
    double height = double.parse(_heightController.text);
    double heightSquared = height * height;
    double imc = weight / heightSquared;
    String result = _calculateResult(imc);

    setState(() {
      _imc = double.parse(imc.toStringAsFixed(1));
      _imcResult = result;
    });
  }

  String _calculateResult(double imc) {
    if(imc == 0.0) return '';
    if (imc < 18.5) {
      return 'Underweight';
    } else if (imc >= 18.5 && imc < 24.9) {
      return 'Normal weight';
    } else if (imc >= 25 && imc < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  void _saveData() async {
    //TODO: Salva na memória do telefone
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight', double.parse(_weightController.text));
    await prefs.setDouble('height', double.parse(_heightController.text));
    await prefs.setInt('age', int.parse(_ageController.text));
    await prefs.setString('sex', _sex);
    await prefs.setDouble('lastIMC', _imc);
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('weight')) return;
    setState(() {
      _weightController.text = prefs.getDouble('weight').toString();
      _heightController.text = prefs.getDouble('height').toString();
      _ageController.text = prefs.getInt('age').toString();
      _sex = prefs.getString('sex') ?? '';
      _imc = prefs.getDouble('lastIMC') ?? 0.0;
      _imcResult = _calculateResult(_imc);
    });
  }
}