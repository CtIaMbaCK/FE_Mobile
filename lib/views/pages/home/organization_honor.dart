import 'package:flutter/material.dart';

class OrganizationHonor extends StatefulWidget {
  const OrganizationHonor({super.key});

  @override
  State<OrganizationHonor> createState() => _OrganizationHonorState();
}

class _OrganizationHonorState extends State<OrganizationHonor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vinh Danh Tổ Chức Xã Hội'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(child: Text('Organization Honor Page')),
    );
  }
}
