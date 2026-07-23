import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const SnakesGameApp());

/// Vivid, glow-friendly colors the player can choose for the snake.
const List<Color> kSnakeColors = [
  Color(0xFF3EE07B), // green
  Color(0xFF3E9BFF), // blue
  Color(0xFFFFB03E), // amber
  Color(0xFFB44DFF), // purple
  Color(0xFFFF5CA8), // pink
  Color(0xFF2FE6E0), // cyan
  Color(0xFFFFE23E), // yellow
];

// Shared palette.
const Color kBgTop = Color(0xFF2A2060);
const Color kBgBottom = Color(0xFF120C2E);
const Color kWallA = Color(0xFF7C4DFF);
const Color kWallB = Color(0xFF25E0E6);
const Color kFood = Color(0xFFFF6B81);

const LinearGradient kScreenGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [kBgTop, kBgBottom],
);

class SnakesGameApp extends StatelessWidget {
  const SnakesGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snakes Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const LoadingPage(),
    );
  }
}

/// A title rendered with the neon wall gradient as its fill.
class GradientTitle extends StatelessWidget {
  final String text;
  final double size;
  final List<Color> colors;

  const GradientTitle(
    this.text, {
    super.key,
    this.size = 40,
    this.colors = const [kWallB, kWallA],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(colors: colors).createShader(rect),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
          color: Colors.white,
          shadows: [
            Shadow(color: colors.last.withOpacity(0.5), blurRadius: 24),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Loading / splash page.
/// ---------------------------------------------------------------------------
class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, a, __) => const StartScreen(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
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
      body: Container(
        decoration: const BoxDecoration(gradient: kScreenGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GradientTitle('SNAKES', size: 46),
              const SizedBox(height: 4),
              Text(
                'G A M E',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 44),
              // The loading bar is a snake that grows to full length.
              SizedBox(
                width: 260,
                height: 90,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _RibbonSnakePainter(
                      color: kSnakeColors.first,
                      progress: _controller.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Start screen: preview + pick a color, then play.
/// ---------------------------------------------------------------------------
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Color _selected = kSnakeColors.first;

  void _play() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, a, __) => SnakeGame(snakeColor: _selected),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kScreenGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GradientTitle('SNAKES GAME', size: 34),
                const SizedBox(height: 28),
                // Live preview of the snake in the chosen color.
                SizedBox(
                  width: 240,
                  height: 96,
                  child: CustomPaint(
                    painter: _RibbonSnakePainter(color: _selected, progress: 1),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Pick your snake color',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final c in kSnakeColors)
                      GestureDetector(
                        onTap: () => setState(() => _selected = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selected == c
                                  ? Colors.white
                                  : Colors.white24,
                              width: _selected == c ? 3 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.withOpacity(_selected == c ? 0.7 : 0.0),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _selected.withOpacity(0.5),
                        blurRadius: 28,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: _play,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selected,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 46, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// The game.
/// ---------------------------------------------------------------------------
class SnakeGame extends StatefulWidget {
  final Color snakeColor;

  const SnakeGame({super.key, required this.snakeColor});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  final List<Offset> _snake = [];
  final Random _random = Random();
  Offset _target = Offset.zero;
  Offset _food = Offset.zero;

  int _score = 0;
  bool _gameOver = false;
  double _time = 0;

  static const int _startSegments = 14;
  static const int _growPerFood = 4;
  static const double _spacing = 13;
  static const double _speed = 260;
  static const double _headRadius = 11;
  static const double _foodRadius = 9;
  static const double _border = 16;

  Size _size = Size.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initGame(Size size) {
    _size = size;
    final center = Offset(size.width / 2, size.height / 2);
    _snake
      ..clear()
      ..addAll(List.filled(_startSegments, center));
    _target = center;
    _score = 0;
    _gameOver = false;
    _lastTick = Duration.zero;
    _spawnFood();
    _initialized = true;
  }

  void _restart() => setState(() => _initGame(_size));

  void _spawnFood() {
    final margin = _border + 34;
    _food = Offset(
      margin + _random.nextDouble() * (_size.width - 2 * margin),
      margin + _random.nextDouble() * (_size.height - 2 * margin),
    );
  }

  void _onTick(Duration elapsed) {
    if (!_initialized || _gameOver) {
      _lastTick = elapsed;
      return;
    }

    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _time = elapsed.inMicroseconds / 1e6;
    if (dt <= 0) return;

    final head = _snake.first;
    final toTarget = _target - head;
    final dist = toTarget.distance;
    Offset newHead = head;
    if (dist > 1) {
      final step = min(_speed * dt, dist);
      newHead = head + (toTarget / dist) * step;
    }
    _snake[0] = newHead;

    for (int i = 1; i < _snake.length; i++) {
      final ahead = _snake[i - 1];
      final diff = ahead - _snake[i];
      final len = diff.distance;
      if (len > _spacing) {
        _snake[i] = ahead - (diff / len) * _spacing;
      }
    }

    // Wall collision -> game over.
    final minX = _border + _headRadius;
    final maxX = _size.width - _border - _headRadius;
    final minY = _border + _headRadius;
    final maxY = _size.height - _border - _headRadius;
    if (newHead.dx < minX ||
        newHead.dx > maxX ||
        newHead.dy < minY ||
        newHead.dy > maxY) {
      setState(() => _gameOver = true);
      return;
    }

    if ((newHead - _food).distance < _headRadius + _foodRadius) {
      _score++;
      final tail = _snake.last;
      _snake.addAll(List.filled(_growPerFood, tail));
      _spawnFood();
    }

    setState(() {});
  }

  void _updateTarget(Offset p) {
    if (!_gameOver) _target = p;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (!_initialized || _size != size) {
            _initGame(size);
          }
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerHover: (e) => _updateTarget(e.localPosition),
            onPointerMove: (e) => _updateTarget(e.localPosition),
            onPointerDown: (e) => _updateTarget(e.localPosition),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GamePainter(
                      snake: List.of(_snake),
                      food: _food,
                      snakeColor: widget.snakeColor,
                      border: _border,
                      headRadius: _headRadius,
                      foodRadius: _foodRadius,
                      time: _time,
                    ),
                  ),
                ),
                _buildScorePill(),
                if (!_gameOver)
                  Positioned(
                    bottom: 22,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Move to steer  •  avoid the walls',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (_gameOver) _buildGameOverOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScorePill() {
    return Positioned(
      top: 20,
      left: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: widget.snakeColor.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, color: kFood, size: 12),
            const SizedBox(width: 8),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GradientTitle(
                  'GAME OVER',
                  size: 40,
                  colors: [Color(0xFFFF9A5A), Color(0xFFFF5C7A)],
                ),
                const SizedBox(height: 16),
                Text(
                  'Score $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: widget.snakeColor.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Play Again'),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.snakeColor,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 34, vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('Change Color / Menu'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Painter for the game field, walls, food, and snake.
/// ---------------------------------------------------------------------------
class _GamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final Color snakeColor;
  final double border;
  final double headRadius;
  final double foodRadius;
  final double time;

  _GamePainter({
    required this.snake,
    required this.food,
    required this.snakeColor,
    required this.border,
    required this.headRadius,
    required this.foodRadius,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          const [kBgTop, kBgBottom],
        ),
    );

    // Faint dotted texture.
    final dot = Paint()..color = Colors.white.withOpacity(0.035);
    const gap = 36.0;
    for (double y = gap; y < size.height; y += gap) {
      for (double x = gap; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.3, dot);
      }
    }

    // Vignette.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          size.center(Offset.zero),
          size.longestSide * 0.7,
          [Colors.transparent, Colors.black.withOpacity(0.35)],
          const [0.6, 1.0],
        ),
    );

    // Neon rounded walls (glow + solid).
    final wallRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          border / 2, border / 2, size.width - border, size.height - border),
      const Radius.circular(22),
    );
    final wallShader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(size.width, size.height),
      const [kWallA, kWallB],
    );
    canvas.drawRRect(
      wallRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = border
        ..shader = wallShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(
      wallRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = border * 0.5
        ..shader = wallShader,
    );

    // Food (pulsing) with glow.
    final pulse = 1 + 0.12 * sin(time * 4);
    final fr = foodRadius * pulse;
    canvas.drawCircle(
      food,
      fr * 2.1,
      Paint()
        ..color = kFood.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(food, fr, Paint()..color = kFood);
    canvas.drawCircle(
      food.translate(-fr * 0.3, -fr * 0.35),
      fr * 0.32,
      Paint()..color = Colors.white.withOpacity(0.75),
    );

    if (snake.isEmpty) return;

    // Glow underlay as one blurred stroke through the body.
    final path = Path()..moveTo(snake.first.dx, snake.first.dy);
    for (int i = 1; i < snake.length; i++) {
      path.lineTo(snake[i].dx, snake[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = headRadius * 1.9
        ..color = snakeColor.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // Tapered body with a head->tail color fade.
    final dark = Color.lerp(snakeColor, const Color(0xFF0B0620), 0.55)!;
    final n = snake.length;
    for (int i = n - 1; i >= 0; i--) {
      final t = i / n;
      final radius = headRadius * (1 - 0.45 * t);
      final color = Color.lerp(snakeColor, dark, t)!;
      canvas.drawCircle(snake[i], radius, Paint()..color = color);
    }

    // Head: specular highlight + eyes.
    final head = snake.first;
    canvas.drawCircle(
      head.translate(-headRadius * 0.3, -headRadius * 0.35),
      headRadius * 0.32,
      Paint()..color = Colors.white.withOpacity(0.25),
    );

    final ahead = snake.length > 1 ? snake[1] : head;
    var dir = head - ahead;
    if (dir.distance < 0.001) dir = const Offset(1, 0);
    dir = dir / dir.distance;
    final perp = Offset(-dir.dy, dir.dx);
    final eyeOffset = headRadius * 0.45;
    final eyeR = headRadius * 0.30;
    for (final s in [1.0, -1.0]) {
      final c = head + dir * (headRadius * 0.3) + perp * (eyeOffset * s);
      canvas.drawCircle(c, eyeR, Paint()..color = Colors.white);
      canvas.drawCircle(
          c + dir * eyeR * 0.35, eyeR * 0.5, Paint()..color = Colors.black87);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}

/// ---------------------------------------------------------------------------
/// A glowing "ribbon" snake along a wavy path, revealed by [progress].
/// Used for the loading bar and the start-screen preview.
/// ---------------------------------------------------------------------------
class _RibbonSnakePainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1
  final int waves;

  _RibbonSnakePainter({
    required this.color,
    required this.progress,
    this.waves = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final amp = size.height * 0.30;
    final path = Path()..moveTo(6, midY);
    const steps = 90;
    for (int i = 1; i <= steps; i++) {
      final x = 6 + (size.width - 12) * i / steps;
      final y = midY + sin(i / steps * waves * 2 * pi) * amp;
      path.lineTo(x, y);
    }

    final metric = path.computeMetrics().first;
    final len = metric.length * progress.clamp(0.0, 1.0);
    if (len <= 0) return;
    final sub = metric.extractPath(0, len);

    // Glow.
    canvas.drawPath(
      sub,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 16
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Body.
    canvas.drawPath(
      sub,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 10
        ..color = color,
    );

    // Head at the leading tip, with eyes facing travel.
    final tan = metric.getTangentForOffset(len);
    if (tan != null) {
      final head = tan.position;
      canvas.drawCircle(
        head,
        13,
        Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(head, 8, Paint()..color = color);
      final dir = tan.vector;
      final perp = Offset(-dir.dy, dir.dx);
      for (final s in [1.0, -1.0]) {
        final c = head + dir * 2 + perp * (3 * s);
        canvas.drawCircle(c, 2.2, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RibbonSnakePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
