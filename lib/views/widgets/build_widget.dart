import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildInputLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: const Color(0xFF12151C),
        ),
      ),
    ),
  );
}

// cho login
Widget buildTextField({
  required TextEditingController controller,
  required String hint,
  IconData? icon,
  bool isPass = false,
  bool isObserved = false,
  Widget? suffixIcon,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: TextField(
      controller: controller,
      obscureText: isObserved,
      keyboardType: keyboardType,
      style: GoogleFonts.roboto(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.roboto(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF008080), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008080), width: 1.5),
        ),
      ),
    ),
  );
}

// nhap lieu binh thuong
Widget buildFormTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  bool isReadOnly = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          style: GoogleFonts.roboto(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint ?? "$label...",
            hintStyle: GoogleFonts.roboto(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F4F8),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF008080),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ),
  );
}

// textarea
Widget buildFormTextArea({
  required TextEditingController controller,
  required String label,
  String? hint,
  int minLines = 1, // Chiều cao mặc định ban đầu (khoảng 4 dòng)
  int? maxLines, // Để null để nó có thể giãn ra vô hạn theo nội dung
  bool isReadOnly = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          readOnly: isReadOnly,
          style: GoogleFonts.roboto(fontSize: 15),
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: hint ?? "$label...",
            hintStyle: GoogleFonts.roboto(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F4F8),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF008080),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
