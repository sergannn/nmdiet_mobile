String money(int minor) {
  final rubles = (minor ~/ 100).toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]} ',
  );
  final fraction = minor % 100;
  return '$rubles${fraction == 0 ? '' : ',${fraction.toString().padLeft(2, '0')}'} ₽';
}
