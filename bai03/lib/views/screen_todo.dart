// lib/views/screen_todo.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/file_services.dart';
import '../services/notification_service.dart'; // BÀI 3

class ScreenTodo extends StatefulWidget {
  const ScreenTodo({super.key}); // SỬA: thêm constructor const + key

  @override
  State<ScreenTodo> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<ScreenTodo> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();
  final NotificationService notificationService = NotificationService();

  // khởi tạo danh sách todo và thời gian chọn
  List<Todo> todos = [];
  DateTime? selectedTime;

  // Bảng màu nền cho từng item (lặp lại theo thứ tự)
  final List<Color> colors = [
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.purple.shade100,
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // SỬA: giải phóng controller khi thoát màn hình
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadData() async {
    final data = await fileService.loadTodos();
    if (!mounted) return;
    setState(() => todos = data);
  }

  void addTodo() async {
    final title = controller.text.trim();

    // SỬA: báo cho người dùng biết thay vì im lặng không làm gì
    if (title.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tên công việc và chọn thời gian"),
        ),
      );
      return;
    }

    final time = selectedTime!;

    // BÀI 3: không cho hẹn giờ đã qua
    if (!time.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thời gian đã qua, hãy chọn lại")),
      );
      return;
    }

    final todo = Todo(title: title, time: time);
    todos.add(todo);
    await fileService.saveTodos(todos);

    // BÀI 3 (1): hiển thị notification đã thêm lịch cho công việc
    await notificationService.showAddedNotification(title, formatTime(time));

    // BÀI 3 (2): thiết lập lịch nhắc theo thời gian đã chọn.
    // id duy nhất cho mỗi công việc để các lịch không ghi đè nhau.
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647;
    await notificationService.scheduleTodoAt(id: id, title: title, time: time);

    controller.clear();
    selectedTime = null;

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã lưu và hẹn nhắc lúc ${formatTime(time)}")),
    );
  }

  // CHỌN NGÀY + GIỜ
  void pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    // SỬA: kiểm tra mounted trước khi dùng context sau await
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String formatTime(DateTime time) {
    return DateFormat("dd/MM/yyyy HH:mm").format(time);
  }

  Color getTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ứng dụng nhắc việc"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // nhập công việc
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Tên công việc",
                filled: true,
                fillColor: Colors.white, // nền trắng
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // chọn thời gian
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? "Chưa chọn thời gian"
                        : formatTime(selectedTime!),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Chọn thời gian",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // lưu
            ElevatedButton(
              onPressed: addTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.blue, width: 1.5),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text("Lưu"),
            ),
            const SizedBox(height: 20),

            // hiển thị danh sách
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final t = todos[index];
                  final Color bgColor = colors[index % colors.length];
                  final Color textColor = getTextColor(bgColor);

                  return Card(
                    color: bgColor, // màu nền theo thứ tự
                    child: ListTile(
                      leading: Icon(Icons.task, color: textColor),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formatTime(t.time),
                        style: TextStyle(
                          // SỬA: withOpacity() đã deprecated -> withValues(alpha:)
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
