import 'dart:convert';

import 'package:flutter/material.dart';
import '../helpers/my_text_field.dart';
import '../helpers/api_caller.dart';
import '../helpers/my_list_tile.dart';
import '../models/web_item.dart';
import '../helpers/dialog_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _field1Controller = TextEditingController();
  final _field2Controller = TextEditingController();
  List<TodoItem> _webitems = [];
  TodoItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await ApiCaller().get("web_types");
      List list = jsonDecode(response);
      setState(() {
        _webitems = list.map((e) => TodoItem.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _handleApiPost() async {
    if (_formKey.currentState!.validate() && selectedItem != null) {
      String url = _field1Controller.text;
      String description = _field2Controller.text;

      // Prepare the data to send in the POST request
      Map<String, dynamic> postData = {
        'url': url,
        'description': description,
        'type': selectedItem!.title,
        // Add more data if needed
      };

      try {
        // Send POST request using ApiCaller
        String response =
            await ApiCaller().post("report_web", params: postData);

        // Extract the ID and report counts from the response JSON
        var jsonResponse = jsonDecode(response);
        int submittedId = jsonResponse['insertItem']['id'];
        Map<String, int> reportCounts = Map.fromIterable(
          jsonResponse['summary'],
          key: (item) => item['title'],
          value: (item) => item['count'],
        );

        // Display success dialog with the submitted ID and report counts
        showOkDialog(
          context: context,
          title: 'Success',
          message:
              'ขอบคุณสำหรับการแจ้งข้อมูล รหัสข้อมูลข้องคุณคือ $submittedId',
          reportCounts: reportCounts,
        );
      } catch (e) {
        // Handle errors when sending the POST request
        showOkDialog(
          context: context,
          title: 'Error',
          message: 'Failed to submit data: $e',
        );
      }
    } else {
      // Show validation error or selection error
      showOkDialog(
        context: context,
        title: 'Error',
        message: 'ต้องกรอก URL และเลือกประเภทเว็บ',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Webby Fondue',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.redAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Center(
            child: Text(
              'ระบบรายงานเว็บเลวๆ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 700.0, // Adjust the width as needed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16.0),
                      const Text('* ต้องกรอกข้อมูล'),
                      const SizedBox(height: 16.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            MyTextField(
                              controller: _field1Controller,
                              hintText: 'URL',
                            ),
                            const SizedBox(height: 16.0),
                            MyTextField(
                              controller: _field2Controller,
                              hintText: 'รายละเอียด',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('ระบุประเภทเว็บเลว *'),
                      const SizedBox(height: 8.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _webitems.length,
                        itemBuilder: (context, index) {
                          final item = _webitems[index];
                          String fullImageUrl =
                              "https://cpsu-api-49b593d4e146.herokuapp.com" +
                                  item.image;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItem = item;
                              });
                            },
                            child: Column(
                              children: [
                                MyListTile(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  imageUrl: fullImageUrl,
                                  selected: selectedItem == item,
                                ),
                                const SizedBox(height: 16.0),
                                if (index ==
                                    _webitems.length -
                                        1) // Add space only after the last item
                                  const SizedBox(
                                      height:
                                          80.0), // Adjust the height as needed
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[200], // Customize button container color
                    child: TextButton(
                      onPressed: _handleApiPost,
                      child: Text(
                        'ส่งข้อมูล',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set button background color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
