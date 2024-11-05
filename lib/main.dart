import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: SolarSystemAnimation()),
      ),
    );
  }
}

class SolarSystemAnimation extends StatefulWidget {
  const SolarSystemAnimation({super.key});

  @override
  State<SolarSystemAnimation> createState() => _SolarSystemAnimationState();
}

class _SolarSystemAnimationState extends State<SolarSystemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = min(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: SolarSystemPainter(_controller, size),
          child: SizedBox(
            width: size,
            height: size,
          ),
        );
      },
    );
  }
}

class SolarSystemPainter extends CustomPainter {
  final Animation<double> animation;
  final double systemSize;

  final List<Map<String, dynamic>> planets = [
    {"name": "Mercury", "color": Colors.grey, "radius": 50.0, "size": 5.0},
    {"name": "Venus", "color": Colors.orange, "radius": 80.0, "size": 6.0},
    {"name": "Earth", "color": Colors.blue, "radius": 110.0, "size": 7.0},
    {"name": "Mars", "color": Colors.red, "radius": 140.0, "size": 6.0},
    {"name": "Jupiter", "color": Colors.brown, "radius": 180.0, "size": 9.0},
    {"name": "Saturn", "color": Colors.amber, "radius": 220.0, "size": 8.0},
    {"name": "Uranus", "color": Colors.lightBlue, "radius": 260.0, "size": 7.0},
    {"name": "Neptune", "color": Colors.indigo, "radius": 300.0, "size": 7.0},
    {"name": "Pluto", "color": Colors.deepPurple, "radius": 330.0, "size": 4.0},
  ];

  SolarSystemPainter(this.animation, this.systemSize) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Galaxy background with soft nebula layers
    final galaxyPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black, Colors.blueGrey.shade900, Colors.deepPurple.shade900],
        stops: const [0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: systemSize));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), galaxyPaint);

    // Soft nebula cloud effect
    final nebulaPaint = Paint()..color = Colors.blueAccent.withOpacity(0.03);
    canvas.drawCircle(center, systemSize * 1.2, nebulaPaint);

    // Draw scattered stars with slow twinkling effect
    final rng = Random();
    for (int i = 0; i < 100; i++) {
      double x = rng.nextDouble() * size.width;
      double y = rng.nextDouble() * size.height;
      double starSize = rng.nextDouble() * 1.5 + 0.5;
      double opacity = 0.3 + 0.3 * sin(animation.value * 2 * pi + i); // Slow twinkling effect
      Paint starPaint = Paint()..color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    // Sun glow effect at the center
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellowAccent.withOpacity(0.5), Colors.transparent],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: systemSize * 0.15));
    canvas.drawCircle(center, systemSize * 0.15, sunGlowPaint);

    // Sun in the center
    Paint sunPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(center, systemSize * 0.06, sunPaint);

    for (int i = 0; i < planets.length; i++) {
      var planet = planets[i];
      double orbitRadius = planet['radius'] as double;
      double planetRadius = planet['size'] as double;

      // Faint orbit to keep focus on planets
      Paint orbitPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, orbitRadius, orbitPaint);

      // Calculate the position of the planet along the orbit
      final planetAngle = animation.value * 2 * pi + (i * pi / 4);
      final planetPosition = Offset(
        center.dx + orbitRadius * cos(planetAngle),
        center.dy + orbitRadius * sin(planetAngle),
      );

      // Shadow for 3D effect
      Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
      canvas.drawCircle(
          Offset(planetPosition.dx + 3, planetPosition.dy + 3), planetRadius, shadowPaint);

      // Gradient for each planet's lighting
      final planetPaint = Paint()
        ..shader = RadialGradient(
          colors: [planet['color'], planet['color'].withOpacity(0.7)],
          stops: const [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: planetPosition, radius: planetRadius));
      canvas.drawCircle(planetPosition, planetRadius, planetPaint);

      // Draw planet names outside each orbit
      TextSpan textSpan = TextSpan(
        text: planet['name'],
        style: const TextStyle(fontSize: 10, color: Colors.white),
      );

      TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        planetPosition.dx - planetRadius,
        planetPosition.dy + planetRadius + 10,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
