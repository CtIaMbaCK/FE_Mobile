import 'package:flutter/material.dart';

class VolunteerHonor extends StatefulWidget {
  const VolunteerHonor({super.key});

  @override
  State<VolunteerHonor> createState() => _VolunteerHonorState();
}

class _VolunteerHonorState extends State<VolunteerHonor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vinh Danh Tình Nguyện Viên'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(child: Text('Volunteer Honor Page')),
    );
  }
}
