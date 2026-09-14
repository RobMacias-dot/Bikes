import 'package:flutter/material.dart';

/// Original BiciFirme vector diagrams. No network, copied images or dimensions.
class RepairVisual extends StatelessWidget {
  const RepairVisual({super.key, required this.id});
  final String id;
  static const captions = {
    'tube_bead':
        'Corte del rin: el borde rígido de la cubierta (azul) se lleva al canal central antes de levantarlo. La cámara debe quedar dentro de la cubierta, nunca entre borde y rin.',
    'chain_arm':
        'Vista lateral simplificada: el brazo con dos rueditas bajo el cambio es la jaula. Con todo inmóvil, se mueve suavemente hacia delante para dar holgura. La flecha apunta hacia los pedales.',
    'disc_gap':
        'Vista a través de la pinza: el disco debe pasar entre las dos pastillas sin tocarlas. Izquierda: separación. Derecha: contacto. No representa tornillos ni un montaje específico.',
  };
  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: const Text('Ver ayuda visual offline'),
        children: [
          Semantics(
              label: captions[id],
              image: true,
              child: SizedBox(
                height: 200,
                width: 360,
                child: CustomPaint(painter: _Diagram(id)),
              )),
          Padding(
              padding: const EdgeInsets.all(12), child: Text(captions[id]!)),
          const Text('Esquema original BiciFirme · sin escala · piloto'),
        ],
      );
}

class _Diagram extends CustomPainter {
  _Diagram(this.id);
  final String id;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 360, size.height / 200);
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, 360, 200), Paint()..color = Colors.white);
    final ink = Paint()
      ..color = const Color(0xff27364b)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final blue = Paint()
      ..color = const Color(0xff006bb3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    void line(double x, double y, double a, double b, Paint p) =>
        canvas.drawLine(Offset(x, y), Offset(a, b), p);
    void label(String text, double x, double y) {
      final t = TextPainter(
          text: TextSpan(
              text: text,
              style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontFamily: 'Roboto')),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: 340);
      t.paint(canvas, Offset(x, y));
    }

    if (id == 'tube_bead') {
      canvas.drawPath(
          Path()
            ..moveTo(80, 80)
            ..lineTo(95, 150)
            ..lineTo(265, 150)
            ..lineTo(280, 80),
          ink);
      canvas.drawPath(
          Path()
            ..moveTo(100, 90)
            ..cubicTo(40, -5, 320, -5, 260, 90),
          blue);
      canvas.drawOval(const Rect.fromLTWH(115, 40, 130, 65), ink);
      line(100, 110, 155, 130, blue);
      line(155, 130, 142, 111, blue);
      line(155, 130, 133, 135, blue);
      label('Cámara', 150, 65);
      label('Rin / canal central', 110, 165);
    } else if (id == 'chain_arm') {
      canvas.drawCircle(const Offset(245, 45), 25, ink);
      canvas.drawCircle(const Offset(215, 130), 20, ink);
      line(229, 61, 201, 117, blue);
      line(263, 63, 232, 142, blue);
      line(193, 136, 106, 136, blue);
      line(106, 136, 123, 122, blue);
      line(106, 136, 123, 150, blue);
      label('Hacia los pedales', 20, 164);
      label('Brazo con dos rueditas', 95, 5);
    } else {
      for (final x in [65.0, 225.0]) {
        canvas.drawRect(Rect.fromLTWH(x, 45, 20, 95), ink);
        canvas.drawRect(Rect.fromLTWH(x + 65, 45, 20, 95), ink);
        final dx = x == 65 ? 42.0 : 61.0;
        line(x + dx, 25, x + dx, 160, blue);
      }
      label('Separación', 60, 170);
      label('Contacto', 230, 170);
      label('Pastillas   | disco |   pastillas', 65, 3);
    }
  }

  @override
  bool shouldRepaint(covariant _Diagram oldDelegate) => id != oldDelegate.id;
}
