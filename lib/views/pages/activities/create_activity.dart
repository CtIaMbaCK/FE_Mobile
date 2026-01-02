import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';

class NewHelpPage extends StatefulWidget {
  final HelpRequestModel? request; // Nhận dữ liệu nếu là chỉnh sửa
  const NewHelpPage({super.key, this.request});

  @override
  State<NewHelpPage> createState() => _NewHelpPageState();
}

class _NewHelpPageState extends State<NewHelpPage> {
  final _formKey = GlobalKey<FormState>();
  final RequestService _requestService = RequestService();
  final ImagePicker _picker = ImagePicker();

  // --- Controllers ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressDetailController =
      TextEditingController();

  // --- State Variables ---
  String? _selectedHelpType;
  String? _selectedDistrict;
  String? _selectedRecurrence = "NONE";

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<File> _selectedImages = [];
  List<String> _existingImageUrls = []; // Lưu các ảnh cũ từ server nếu có

  // --- MAPPING DATA ENUMS ---
  final Map<String, String> _typeMap = {
    'Giáo dục': 'EDUCATION',
    'Y tế': 'MEDICAL',
    'Công việc nhà': 'HOUSE_WORK',
    'Vận chuyển': 'TRANSPORT',
    'Thực phẩm': 'FOOD',
    'Chỗ ở': 'SHELTER',
    'Khác': 'OTHER',
  };

  final Map<String, String> _districtMap = {
    'Quận 1': 'QUAN_1',
    'Quận 3': 'QUAN_3',
    'Quận 4': 'QUAN_4',
    'Quận 5': 'QUAN_5',
    'Quận 6': 'QUAN_6',
    'Quận 7': 'QUAN_7',
    'Quận 8': 'QUAN_8',
    'Quận 10': 'QUAN_10',
    'Quận 11': 'QUAN_11',
    'Quận 12': 'QUAN_12',
    'Bình Tân': 'BINH_TAN',
    'Bình Thạnh': 'BINH_THANH',
    'Gò Vấp': 'GO_VAP',
    'Phú Nhuận': 'PHU_NHUAN',
    'Tân Bình': 'TAN_BINH',
    'Tân Phú': 'TAN_PHU',
    'TP. Thủ Đức': 'TP_THU_DUC',
    'H. Bình Chánh': 'HUYEN_BINH_CHANH',
    'H. Cần Giờ': 'HUYEN_CAN_GIO',
    'H. Củ Chi': 'HUYEN_CU_CHI',
    'H. Hóc Môn': 'HUYEN_HOC_MON',
    'H. Nhà Bè': 'HUYEN_NHA_BE',
  };

  final Map<String, String> _recurrenceMap = {
    'Không lặp lại': 'NONE',
    'Hàng ngày': 'DAILY',
    'Hàng tuần': 'WEEKLY',
    'Tùy chỉnh': 'CUSTOM',
  };

  @override
  void initState() {
    super.initState();
    // Nếu là CHỈNH SỬA, đổ dữ liệu cũ vào các trường
    if (widget.request != null) {
      final req = widget.request!;
      _titleController.text = req.title;
      _descriptionController.text = req.description ?? "";
      _addressDetailController.text = req.addressDetail;
      _selectedHelpType = req.activityType;
      _selectedDistrict = req.district;
      _selectedRecurrence = req.recurrence;
      _startDate = req.startDate;
      _endDate = req.endDate;
      _startTime = TimeOfDay.fromDateTime(req.startTime);
      _endTime = TimeOfDay.fromDateTime(req.endTime);
      _existingImageUrls = req.activityImages;
    }
  }

  // --- Logic Functions ---
  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)).toList());
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2030),
    );
    if (picked != null)
      setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null)
      setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  String _combineDateTime(DateTime date, TimeOfDay time) {
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dt.toUtc().toIso8601String();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin thời gian"),
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {
      "title": _titleController.text,
      "activityType": _selectedHelpType,
      "description": _descriptionController.text,
      "district": _selectedDistrict,
      "addressDetail": _addressDetailController.text,
      "startDate": DateFormat('yyyy-MM-dd').format(_startDate!),
      "endDate": DateFormat('yyyy-MM-dd').format(_endDate!),
      "startTime": _combineDateTime(_startDate!, _startTime!),
      "endTime": _combineDateTime(_endDate!, _endTime!),
      "recurrence": _selectedRecurrence,
      "activityImages": _existingImageUrls.isNotEmpty
          ? _existingImageUrls
          : [
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbj_SXUeWP4_QMm_Q0B0lmBfze8BiAQhCTmg&s",
            ],
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success;
    if (widget.request != null) {
      success = await _requestService.updateRequest(widget.request!.id, body);
    } else {
      success = await _requestService.createRequest(body);
    }

    Navigator.pop(context); // Tắt loading

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi thao tác, vui lòng kiểm tra lại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.request != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Chỉnh Sửa Yêu Cầu' : 'Tạo Yêu Cầu Mới',
          style: GoogleFonts.readexPro(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tiêu đề'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration(
                  hintText: 'VD: Cần người dọn dẹp nhà cửa',
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),

              const SizedBox(height: 16),
              _buildLabel('Loại hỗ trợ'),
              DropdownButtonFormField<String>(
                initialValue: _selectedHelpType,
                items: _typeMap.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.value, child: Text(e.key)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedHelpType = v),
                decoration: _buildInputDecoration(hintText: 'Chọn danh mục'),
              ),

              const SizedBox(height: 16),
              _buildLabel('Quận / Huyện'),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                items: _districtMap.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.value, child: Text(e.key)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedDistrict = v),
                decoration: _buildInputDecoration(hintText: 'Chọn khu vực'),
              ),

              const SizedBox(height: 16),
              _buildLabel('Địa chỉ chi tiết'),
              TextFormField(
                controller: _addressDetailController,
                decoration: _buildInputDecoration(
                  hintText: 'Số nhà, tên đường...',
                ),
              ),

              const SizedBox(height: 16),
              _buildLabel('Lặp lại'),
              DropdownButtonFormField<String>(
                initialValue: _selectedRecurrence,
                items: _recurrenceMap.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.value, child: Text(e.key)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedRecurrence = v),
                decoration: _buildInputDecoration(),
              ),

              const SizedBox(height: 16),
              _buildLabel('Mô tả chi tiết'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hintText: 'Mô tả nhu cầu của bạn...',
                ),
              ),

              const SizedBox(height: 24),
              _buildLabel('Thời gian bắt đầu'),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerBox(
                      label: _startDate == null
                          ? "Ngày bắt đầu"
                          : DateFormat('dd/MM/yyyy').format(_startDate!),
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerBox(
                      label: _startTime == null
                          ? "Giờ bắt đầu"
                          : _startTime!.format(context),
                      icon: Icons.access_time,
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildLabel('Thời gian kết thúc'),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerBox(
                      label: _endDate == null
                          ? "Ngày kết thúc"
                          : DateFormat('dd/MM/yyyy').format(_endDate!),
                      icon: Icons.calendar_month,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerBox(
                      label: _endTime == null
                          ? "Giờ kết thúc"
                          : _endTime!.format(context),
                      icon: Icons.timer_outlined,
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel('Hình ảnh minh họa'),
              _buildImagePicker(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008080),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'CẬP NHẬT THAY ĐỔI' : 'GỬI YÊU CẦU',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.readexPro(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _buildPickerBox({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF008080)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 85,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._selectedImages.map(
            (file) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) => InputDecoration(
    hintText: hintText,
    fillColor: Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
