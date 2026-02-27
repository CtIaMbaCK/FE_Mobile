import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration buildInputDecoration({
    required String label,
    required double border,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.roboto(
        color: const Color(0xFF57636C),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFF1F4F8), width: 2),
        borderRadius: BorderRadius.circular(border),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff008080), width: 2),
        borderRadius: BorderRadius.circular(border),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(border),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE0E3E7), width: 2),
        borderRadius: BorderRadius.circular(border),
      ),
      filled: true,
      fillColor: const Color(0xFFF1F4F8),
      contentPadding: const EdgeInsets.all(24),
    );
  }
