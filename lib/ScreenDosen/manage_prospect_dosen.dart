import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bookingroom/utils/pending_booking_prodi.dart';
import 'package:bookingroom/utils/restApi.dart';
import 'package:bookingroom/utils/config.dart';
import 'package:bookingroom/utils/notifikasi_model.dart';
import 'package:intl/intl.dart';

class ManageProspectDosenPage extends StatefulWidget {
  @override
  _ManageProspectDosenPageState createState() => _ManageProspectDosenPageState();
}

class _ManageProspectDosenPageState extends State<ManageProspectDosenPage> {
  List<PendingBookingProdiModel> _prospects = [];
  DataService ds = DataService();

  Future<void> selectAllSchedule() async {
    try {
      String response = await ds.selectAll(token, project, 'pending_booking_prodi', appid);
      List<dynamic> data = jsonDecode(response);
      setState(() {
        _prospects = data.map((e) => PendingBookingProdiModel.fromJson(e)).toList();
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _showDetailDialog(PendingBookingProdiModel prospect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detail Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Date:', prospect.date),
                _buildDetailRow('Start Time:', prospect.start_time),
                _buildDetailRow('End Time:', prospect.end_time),
                _buildDetailRow('Status:', prospect.status),
                _buildDetailRow('Description:', prospect.desc),
                _buildDetailRow('Room:', prospect.room),
                _buildDetailRow('Capacity:', prospect.capacity.toString()),
                _buildDetailRow('User:', prospect.user),
                SizedBox(height: 16),
                if (prospect.status != 'Approved' && prospect.status != 'Canceled')
                  _buildStatusDropdown(prospect),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('Close',style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(PendingBookingProdiModel prospect) {
    return DropdownButton<String>(
      value: prospect.status,
      dropdownColor: Colors.grey[800],
      style: TextStyle(color: Colors.white),
      items: <String>['Pending', 'Approved', 'Canceled']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          if (newValue == 'Canceled') {
            _showCancelDialog(prospect);
          } else {
            _updateStatus(_prospects.indexOf(prospect), newValue);
            Navigator.of(context).pop(); // Close the dialog
          }
        }
      },
    );
  }

    void _showCancelDialog(PendingBookingProdiModel prospect) {
  TextEditingController reasonController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancel Booking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: TextField(
                  controller: reasonController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Please provide a reason for cancellation...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please provide a reason for cancellation'),
                            backgroundColor: Colors.red[400],
                          ),
                        );
                        return;
                      }
                      _updateStatus(
                        _prospects.indexOf(prospect),
                        'Canceled',
                        reason: reasonController.text,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _updateStatus(int index, String newStatus, {String reason = ' '}) async {
  String updateField = 'status';
  String updateValue = newStatus;
  String id = _prospects[index].id;
  String startTime = _prospects[index].start_time;
  String date = _prospects[index].date;
  String endTime = _prospects[index].end_time;
  String desc = _prospects[index].desc;
  String room = _prospects[index].room;
  String capacity = _prospects[index].capacity.toString();
  String user = _prospects[index].user;
  String notifiactionTitle = 'Booking Canceled';
  String statCancel = 'Rejected By Prodi';
  String statApprove = 'Approved By Prodi';

  print('Updating status for ID: $id');
  print('updateField: $updateField');
  print('updateValue: $updateValue');

  try {
    String timeStr = startTime.split(' ')[0];
    List<String> timeParts = timeStr.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    DateTime startDateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      hour,
      minute,
    );

    DateTime workingStartTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      7,
    );

    DateTime workingEndTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      17,
    );

    bool success = await ds.updateId(
      updateField,
      updateValue,
      token,
      project,
      'pending_booking_prodi',
      appid,
      id,
    );

    if (success) {
      if (newStatus != 'Canceled') {
        final String resetStatus = 'Pending';
        if (startDateTime.isAfter(workingStartTime) && startDateTime.isBefore(workingEndTime)) {
          await ds.insertPendingBookingFakultas(
            appid,
            date,
            startTime,
            endTime,
            resetStatus,
            desc,
            room,
            capacity,
            user,
          );
        } else {
          await ds.insertPendingBookingBku(
            appid,
            date,
            startTime,
            endTime,
            resetStatus,
            desc,
            room,
            capacity,
            user,
          );
        }
      }
      final String resetStatus = 'Pending';
      if (newStatus == 'Canceled') {
        await ds.insertNotifikasi(
          appid,
          user,
          reason,
          notifiactionTitle,
        );

        await ds.insertBooking(
          appid,
          date,
          startTime,
          endTime,
          newStatus,
          desc,
          user,
          room,
          statCancel,
          '',
          '',
        );
      }
      if (newStatus == 'Approved') {
          await ds.insertBooking(
            appid,
            date,
            startTime,
            endTime,
            resetStatus,
            desc,
            user,
            room,
            statApprove,
            '',
            ''
          );
        }

      // Update status booking pada UI
      setState(() {
        _prospects[index].status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status')),
      );
    }
  } catch (e) {
    print('Error in _updateStatus: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating status: $e')),
    );
  }
}



  @override
  void initState() {
    super.initState();
    selectAllSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'Manage Prospects Prodi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _prospects.length,
                    itemBuilder: (context, index) {
                      final prospect = _prospects[index];
                      return Card(
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(prospect.date, style: TextStyle(color: Colors.white)),
                          subtitle: Text(prospect.user, style: TextStyle(color: Colors.white)),
                          onTap: () => _showDetailDialog(prospect),
                          trailing: Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'login_screen');
              },
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}