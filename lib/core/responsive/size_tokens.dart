import 'size_config.dart';

// MUST READ: Statik pixel (Padding: 16, fontSize: 14 vb.) kesinlikle YASAK.
// Tüm ölçüler bu dosyadan veya .w / .h extensionları üzerinden verilmelidir.
// iPhone 13 (390x844) referans alınmıştır.
class SizeTokens {
  // Padding & Margin
  static double get p4 => 1.0.w;
  static double get p8 => 2.0.w;
  static double get p12 => 3.1.w;
  static double get p16 => 4.1.w; // ~16px on 390px
  static double get p20 => 5.1.w;
  static double get p24 => 6.2.w;
  static double get p32 => 8.2.w;
  static double get p40 => 10.2.w;
  static double get p48 => 12.3.w;

  // Radius
  static double get r4 => 1.0.w;
  static double get r8 => 2.0.w;
  static double get r10 => 2.5.w;
  static double get r12 => 3.1.w;
  static double get r16 => 4.1.w;
  static double get r20 => 5.1.w;
  static double get r24 => 6.2.w;
  static double get r32 => 8.2.w;
  static double get r100 => 25.6.w;

  // Font Sizes
  static double get f10 => 2.5.w;
  static double get f12 => 3.1.w;
  static double get f14 => 3.6.w;
  static double get f16 => 4.1.w;
  static double get f18 => 4.6.w;
  static double get f20 => 5.1.w;
  static double get f24 => 6.2.w;
  static double get f28 => 7.2.w;
  static double get f32 => 8.2.w;

  // Icon Sizes
  static double get i16 => 4.1.w;
  static double get i20 => 5.1.w;
  static double get i24 => 6.2.w;
  static double get i32 => 8.2.w;
  static double get i48 => 12.3.w;

  // Height & Width tokens
  static double get h12 => 3.1.w;
  static double get h20 => 5.1.w;
  static double get h24 => 6.2.w;
  static double get h32 => 8.2.w;
  static double get h48 => 12.3.w;
  static double get h52 => 13.3.w;
  static double get h60 => 15.4.w;
  static double get h80 => 20.5.w;
  static double get h100 => 25.6.w;
  static double get w100 => 25.6.w;
  static double get h120 => 30.7.w;
  static double get h150 => 38.5.w;
  static double get h200 => 51.3.w;
  static double get h300 => 76.9.w;
}
