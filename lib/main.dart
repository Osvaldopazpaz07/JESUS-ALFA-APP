import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Paleta de Colores ---
// Negro: 80%
const Color primaryBgColor = Color(0xFF000000); // Fondo principal
const Color displayBgColor = Color(0xFF000000); // Fondo de la pantalla de resultados
const Color keyboardBgColor = Color(0xFF121212); // Fondo del teclado (negro muy oscuro)
const Color numberButtonColor = Color(0xFF212121); // Botones de números (negro oscuro)
const Color functionButtonColor = Color(0xFF212121); // Botones de funciones (negro oscuro)
const Color controlButtonColor = Color(0xFF9E9E9E); // Botones de control (gris)

// Blanco: 15%
const Color textColor = Color(0xFFFFFFFF); // Texto principal
const Color operatorButtonColor = Color(0xFFFFFFFF); // Botones de operadores (antes blanco)
const Color operatorTextColor = Color(0xFF000000); // Texto sobre botones de operadores (negro)

// Azul Oscuro: 5%
const Color darkBlueColor = Color(0xFF0D47A1); // Azul oscuro para acentos

// --- Diseños del Teclado ---
const List<String> standardKeys = [
  'AC', '(', ')', '÷',
  '7', '8', '9', '×',
  '4', '5', '6', '-',
  '1', '2', '3', '+',
  '0', '.', '⌫', '=',
];

// --- Teclado Científico Corregido (Incluye +) ---
// Reorganizado para incluir el operador + y mantener 5 columnas sin espacios vacíos.
const List<String> scientificKeys = [
  // Fila 1: Controles principales
  'AC',    '⌫',     '(',     ')',    '%',
  // Fila 2: Trigonométricas y número
  'sin',   'sin⁻¹', '7', '8', '9',
  // Fila 3: Trigonométricas y número
  'cos',   'cos⁻¹', '4', '5', '6',
  // Fila 4: Trigonométricas y número
  'tan',   'tan⁻¹', '1', '2', '3',
  // Fila 5: Logaritmos, número, punto, igual
  'log',   'ln',    '0', '.', '=',
  // Fila 6: Raíz, potencia, operadores básicos
  '√',     'x²',    '+', '÷', '×', // + colocado aquí
  // Fila 7: Potencia, factorial, inverso, operador
  '^',     'x!',    '1/x', '-', // - colocado aquí
  // Fila 8: Constantes y funciones hiperbólicas
  'e',     'π',     'sinh', 'cosh', 'tanh', // + ya está en la fila 6
];

// URL de la política de privacidad (¡recuerda cambiarla!)
const String _privacyPolicyUrl = 'https://jesus-marquez.com/politica-de-privacidad-nexus-calculator/  ';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(ScientificCalculatorApp(isFirstLaunch: isFirstLaunch));
}

class ScientificCalculatorApp extends StatelessWidget {
  final bool isFirstLaunch;
  const ScientificCalculatorApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Científica Futurista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryBgColor,
        scaffoldBackgroundColor: primaryBgColor, // Fondo principal de la app ahora es negro
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: textColor, displayColor: textColor),
      ),
      home: isFirstLaunch ? const ConsentScreen() : const SplashScreen(),
    );
  }
}

// --- Pantalla de Consentimiento ---
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    if (!mounted) return;

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const SplashScreen()));
  }

  Future<void> _launchURL() async {
    if (!await launchUrl(Uri.parse(_privacyPolicyUrl))) {
      debugPrint('Could not launch $_privacyPolicyUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor, // Fondo negro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined,
                  color: operatorButtonColor, size: 80), // Icono blanco
              const SizedBox(height: 20),
              Text(
                'Bienvenido a JESUS ALFA',
                style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor), // Texto blanco
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Gracias por usar nuestra calculadora.\n\nAl continuar, aceptas nuestra Política de Privacidad.',
                style: TextStyle(
                    fontSize: 16, color: textColor.withAlpha(204), height: 1.5), // Texto blanco semi-transparente
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _launchURL,
                child: const Text(
                  'Leer Política de Privacidad',
                  style: TextStyle(
                      fontSize: 16,
                      color: operatorButtonColor, // Texto blanco
                      decoration: TextDecoration.underline,
                      decorationColor: operatorButtonColor), // Subrayado blanco
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: operatorButtonColor, // Fondo blanco
                  foregroundColor: operatorTextColor, // Texto negro
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _acceptConsent,
                child: const Text('Aceptar y Continuar',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Pantalla de Inicio (Splash Screen) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const CalculatorHomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor, // Fondo negro para la splash screen
      body: CustomPaint(
        painter: MatrixPainter(animation: _controller),
        child: Container(),
      ),
    );
  }
}

class MatrixPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_MatrixColumn> _columns = [];
  final Random _random = Random();
  final _characters = '0123456789+-×÷=√∫∑∞πτ∀∃∂∇±≤≥≠';

  MatrixPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (_columns.isEmpty) {
      final columnCount = (size.width / 16).floor();
      for (int i = 0; i < columnCount; i++) {
        _columns.add(_MatrixColumn(
            x: i * 16.0,
            size: size,
            random: _random,
            characters: _characters));
      }
    }

    // Pintar fondo negro
    final backgroundPaint = Paint()..color = primaryBgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Pintar texto "JESUS ALFA" en blanco
    final textStyle = GoogleFonts.orbitron(
      color: Colors.white.withAlpha((255 * 0.08).round()), // Texto blanco muy tenue
      fontSize: 90,
      fontWeight: FontWeight.bold,
      letterSpacing: 4,
    );
    final textSpan = TextSpan(
      text: 'JESUS ALFA',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: size.width, maxWidth: size.width);
    final offset = Offset(0, (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, offset);

    for (var column in _columns) {
      column.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MatrixColumn {
  final double x;
  final Size size;
  final Random random;
  final String characters;
  late List<String> _glyphs;
  late double _yPosition;
  late double _speed;

  _MatrixColumn(
      {required this.x,
      required this.size,
      required this.random,
      required this.characters}) {
    _reset();
  }

  void _reset() {
    _yPosition = -random.nextDouble() * size.height * 1.5;
    _speed = random.nextDouble() * 20 + 15;
    final length = random.nextInt(30) + 20;
    _glyphs = List.generate(
        length, (_) => characters[random.nextInt(characters.length)]);
  }

  void draw(Canvas canvas) {
    const fontSize = 16.0;
    final textStyle = TextStyle(
      fontFamily: GoogleFonts.robotoMono().fontFamily,
      fontSize: fontSize,
    );
    for (int i = 0; i < _glyphs.length; i++) {
      final y = _yPosition + (i * fontSize);
      if (y > 0 && y < size.height) {
        double opacity = 1.0 - (i / (_glyphs.length * 1.5));
        opacity = opacity.clamp(0.1, 1.0);
        Color charColor = i == _glyphs.length - 1
            ? Colors.white.withAlpha((255 * opacity.clamp(0.8, 1.0)).round()) // Letra principal más opaca
                        : Colors.white.withAlpha((255 * opacity * 0.5).round()); // Letras secundarias más transparentes
        final textSpan = TextSpan(
          text: _glyphs[i],
          style: textStyle.copyWith(color: charColor),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    _yPosition += _speed;
    if (_yPosition - (_glyphs.length * fontSize) > size.height) {
      _reset();
    }
  }
}

// --- Página Principal de la Calculadora ---
class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});
  @override
  CalculatorHomePageState createState() => CalculatorHomePageState();
}

class CalculatorHomePageState extends State<CalculatorHomePage> {
  String _expression = '';
  String _output = '0';
  bool _isScientificMode = true;
  bool _isResultOnScreen = false;

  void _onButtonPressed(String buttonText) {
    if (buttonText == ' ') return; // Esta condición maneja el espacio vacío si acaso
    setState(() {
      if (buttonText == 'AC') {
        _handleClear();
      } else if (buttonText == '⌫') {
        _handleBackspace();
      } else if (buttonText == '=') {
        _handleEquals();
      } else {
        _handleInput(buttonText);
      }
    });
  }

  void _handleClear() {
    _expression = '';
    _output = '0';
    _isResultOnScreen = false;
  }

  void _handleBackspace() {
    if (_isResultOnScreen || _output == 'Error de Sintaxis') {
      _handleClear();
      return;
    }
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _output = _expression.isEmpty ? '0' : _expression;
    }
    _isResultOnScreen = false;
  }

  void _handleEquals() {
    if (_output == 'Error de Sintaxis' || _expression.isEmpty) return;
    try {
      String finalExpression = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', 'pi')
          .replaceAll('√', 'sqrt')
          .replaceAll('sin⁻¹', 'asin')
          .replaceAll('cos⁻¹', 'acos')
          .replaceAll('tan⁻¹', 'atan');

      // Reemplazos más seguros para funciones hiperbólicas y factorial
      // Ahora que 'sinh', 'cosh', 'tanh' son entradas directas, se manejan aquí.
      // Ejemplo para sinh(x):
      finalExpression = finalExpression.replaceAllMapped(RegExp(r'sinh\(([^)]+)\)'), (match) {
        String arg = match.group(1)!;
        return '(0.5 * (exp($arg) - exp(-($arg))))';
      });
      finalExpression = finalExpression.replaceAllMapped(RegExp(r'cosh\(([^)]+)\)'), (match) {
        String arg = match.group(1)!;
        return '(0.5 * (exp($arg) + exp(-($arg))))';
      });
      finalExpression = finalExpression.replaceAllMapped(RegExp(r'tanh\(([^)]+)\)'), (match) {
        String arg = match.group(1)!;
        return '((exp($arg) - exp(-($arg))) / (exp($arg) + exp(-($arg))))';
      });

      finalExpression = finalExpression.replaceAllMapped(RegExp(r'(\d+\.?\d*)!'), (match) => 'factorial(${match.group(1)})');
      
      // Manejo de log base 10
      if (finalExpression.contains(RegExp(r'log\(')) && !finalExpression.contains(RegExp(r'log\(\d+,'))) {
        finalExpression = finalExpression.replaceAll(RegExp(r'log\('), 'log(10,');
      }

  final p = ShuntingYardParser();
  final exp = p.parse(finalExpression);
      final cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      _output = _formatResult(result);
      _expression = _output;
      _isResultOnScreen = true;
    } catch (e) {
      _output = 'Error de Sintaxis';
      _expression = '';
      _isResultOnScreen = true;
    }
  }

  void _handleInput(String buttonText) {
    if (_isResultOnScreen) {
      if (!['+', '-', '×', '÷', '^', '%'].contains(buttonText)) {
        _expression = '';
      }
      _isResultOnScreen = false;
    }

    if (_output == 'Error de Sintaxis') {
      _expression = '';
    }

    if (buttonText == '.') {
      var numbers = _expression.split(RegExp(r'[\+\-\×\÷\^\(\)\%\!\\s]'));
      if (numbers.isNotEmpty && numbers.last.contains('.')) return;
    }

    if (_expression == '0' && buttonText != '.') {
      _expression = '';
    }

    if ([
      'sin', 'cos', 'tan', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹', 'log', 'ln',
      'sinh', 'cosh', 'tanh', '√'
    ].contains(buttonText)) {
      _expression += '$buttonText(';
    } else if (buttonText == 'x²') {
      _expression += '^2';
    } else if (buttonText == '1/x') {
      _expression += '1/(';
    } else if (buttonText == 'x!') {
      _expression += '!';
    } else {
      _expression += buttonText;
    }
    _output = _expression.isEmpty ? '0' : _expression;
  }

  String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) {
      return 'Error';
    }
    if (result.truncateToDouble() == result) {
      return result.toInt().toString();
    } else {
      String formatted = result.toStringAsFixed(8);
      if (formatted.length > 15) {
        formatted = result.toStringAsPrecision(10);
      }
      return formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBgColor, // Fondo negro principal
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- Pantalla de Resultados ---
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: displayBgColor.withAlpha((255 * 0.7).round()), // Fondo negro semi-transparente
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? ' ' : _expression,
                        style: TextStyle(
                            fontSize: 24,
                            color: textColor.withAlpha((255 * 0.5).round())), // Texto blanco semi-transparente
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _output,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: _output.length > 8 ? 60 : 80,
                          fontWeight: FontWeight.w300,
                          color: textColor, // Texto blanco
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- Controles (Selector de Modo e Info) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _modeSelector(),
                  const SizedBox(width: 16),
                  _infoButton(context),
                ],
              ),
            ),
            // --- Teclado ---
            Expanded(
              flex: _isScientificMode ? 5 : 4,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: keyboardBgColor.withAlpha((255 * 0.85).round()), // Fondo del teclado negro
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: _isScientificMode
                    ? _buildKeyboard(scientificKeys, 5) // 5 columnas para el modo científico
                    : _buildKeyboard(standardKeys, 4), // 4 columnas para el modo estándar
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(List<String> keys, int crossAxisCount) {
    // Filtrar los espacios vacíos antes de construir la cuadrícula
    List<String> validKeys = keys.where((key) => key != ' ').toList();
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisCount == 5 ? 12 : 16,
        mainAxisSpacing: crossAxisCount == 5 ? 12 : 16,
      ),
      itemCount: validKeys.length, // Usar la longitud de la lista filtrada
      itemBuilder: (context, index) => _buildButton(validKeys[index]), // Obtener la tecla de la lista filtrada
    );
  }

  Widget _buildButton(String buttonText) {
    // Esta función ya ignora los botones con texto ' ' gracias a la línea `if (buttonText == ' ') return Container();` en _onButtonPressed
    // y al filtrado en _buildKeyboard, pero se mantiene por coherencia si se reintrodujera un ' ' accidentalmente.
    if (buttonText == ' ') return Container(); // Espacio vacío es un contenedor vacío

    final color = _getButtonColor(buttonText);
    final textColor = _getTextColor(buttonText);
    final fontSize = ['sin⁻¹', 'cos⁻¹', 'tan⁻¹'].contains(buttonText) ? 16.0 : 24.0;
    final isOperatorButton = ['÷', '×', '-', '+', '='].contains(buttonText);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _onButtonPressed(buttonText),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.white.withAlpha((255 * 0.1).round())),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight:
                  isOperatorButton ? FontWeight.w500 : FontWeight.w300,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(String buttonText) {
    if (['÷', '×', '-', '+', '='].contains(buttonText)) return operatorTextColor; // Negro
    if (['AC', '⌫'].contains(buttonText)) return textColor; // Blanco
    return textColor; // Blanco
  }

  Color _getButtonColor(String buttonText) {
    if (['÷', '×', '-', '+', '='].contains(buttonText)) {
      return operatorButtonColor; // Blanco
    }
    if (['AC', '⌫'].contains(buttonText)) {
      return controlButtonColor; // Gris
    }
    if (RegExp(r'[0-9\.]').hasMatch(buttonText)) {
      return numberButtonColor; // Negro
    }
    return functionButtonColor; // Negro
  }

  Widget _modeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: functionButtonColor, // Fondo negro
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _modeButton('Estándar', !_isScientificMode),
          _modeButton('Científica', _isScientificMode),
        ],
      ),
    );
  }

  Widget _modeButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _isScientificMode = title == 'Científica';
        _handleClear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? operatorButtonColor : Colors.transparent, // Activo Blanco, Inactivo Transparente
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? operatorTextColor : textColor, // Activo Negro, Inactivo Blanco
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _infoButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, color: controlButtonColor), // Icono gris
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: keyboardBgColor, // Fondo del diálogo negro
            title: const Text('Acerca de JESUS ALFA'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Versión 1.0.0'),
                  const SizedBox(height: 10),
                  const Text('Una calculadora científica y estándar.'),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      // Use the _launchURL method from the ConsentScreenState
                      // or define a similar method in CalculatorHomePageState if needed.
                      // For now, we'll just call the same logic directly.
                      if (!await launchUrl(Uri.parse(_privacyPolicyUrl))) {
 debugPrint('Could not launch $_privacyPolicyUrl');
                      }
                    },
                    child: const Text('Política de Privacidad',
                        style: TextStyle(
                            color: operatorButtonColor, // Texto blanco
                            decoration: TextDecoration.underline,
                            decorationColor: operatorButtonColor)), // Subrayado blanco
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar',
                    style: TextStyle(color: operatorButtonColor)), // Texto blanco
              ),
            ],
          ),
        );
      },
    );
  }
}