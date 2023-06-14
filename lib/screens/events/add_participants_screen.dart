import 'package:calendar_app/models/user_checkbox_data.dart';
import 'package:flutter/material.dart';

class AddParticipantsScreen extends StatefulWidget {
  final List<UserCheckboxData> users;
  const AddParticipantsScreen({super.key, required this.users});

  @override
  State<AddParticipantsScreen> createState() => _AddParticipantsScreenState();
}

class _AddParticipantsScreenState extends State<AddParticipantsScreen> {
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: popScreen,
        ),
        title: const Text("Katılımcıları düzenle"),
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 32),
              itemCount: widget.users.length,
              itemBuilder: (context, index) => _getCheckBox(index),
              separatorBuilder: (context, index) => const SizedBox(height: 32),
            ),
    );
  }

  CheckboxListTile _getCheckBox(int index) {
    return CheckboxListTile(
      title: Text(
        "${widget.users[index].user.name} ${widget.users[index].user.surname}",
      ),
      subtitle: Text("@${widget.users[index].user.username}"),
      secondary: const Icon(Icons.account_circle_outlined),
      value: widget.users[index].checked,
      onChanged: (val) => changeCheckStatus(index: index, val: val),
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
    );
  }

  void popScreen() {
    Navigator.of(context).pop(widget.users);
  }

  void changeCheckStatus({required int index, required bool? val}) {
    if (val == null) return;

    setState(() {
      widget.users[index].checked = val;
    });
  }
}
