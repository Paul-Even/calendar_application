import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calendar Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyCalendar(),
    );
  }
}

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});
  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  DataSource events = DataSource(<Appointment>[]);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            title: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final Appointment newEvent = await Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => AddPage())));
                if (newEvent != null) {
                  List<String>? x = prefs.getStringList("events");
                  setState(() {
                    events.appointments!.add(newEvent);
                    x!.add(
                        "${newEvent.subject};${newEvent.startTime};${newEvent.endTime};");
                    prefs.setStringList("events", x);
                  });

                  events.notifyListeners(
                      CalendarDataSourceAction.add, <Appointment>[newEvent]);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String>? x = prefs.getStringList("events");
                List<Appointment> y = getEventsSaved(prefs);
                if (_selectedAppointment != null) {
                  x!.removeAt(y.indexOf(_selectedAppointment));
                  prefs.setStringList("events", x);
                  events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[]..add(_selectedAppointment));
                }
              },
            ),
            IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    List<Appointment> sync = getEventsSaved(prefs);
                    events.notifyListeners(
                        CalendarDataSourceAction.remove, events.appointments!);
                    events.notifyListeners(CalendarDataSourceAction.add, sync);
                  });
                },
                icon: const Icon(Icons.sync))
          ],
        )),
        body: SfCalendar(
          view: CalendarView.day,
          firstDayOfWeek: 1,
          initialDisplayDate: DateTime.now(),
          dataSource: events,
          onTap: calendarTapped,
        ),
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String _title = "";
  String _description = "";
  DateTime date = DateTime.now();
  TimeOfDay start = TimeOfDay.now();
  TimeOfDay end = TimeOfDay.now();
  var newEvent;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () => {
                newEvent = Appointment(
                    startTime: DateTime(date.year, date.month, date.day,
                        start.hour, start.minute),
                    endTime: DateTime(
                        date.year, date.month, date.day, end.hour, end.minute),
                    subject: _title + "\n" + _description),
                Navigator.pop(context, newEvent)
              },
            ),
          ),
          body: Container(
            child: ListView(children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 0, 30),
                title: TextField(
                  controller: TextEditingController(text: _title),
                  onChanged: (String value) {
                    _title = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Add your title here.',
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                title: TextField(
                  controller: TextEditingController(text: _description),
                  onChanged: (String value) {
                    _description = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Add your description here.',
                  ),
                ),
              ),
              ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(15, 30, 0, 0),
                  title: GestureDetector(
                      child: Text(
                        "${date.day}/${date.month}/${date.year}",
                        style: TextStyle(fontSize: 35),
                      ),
                      onTap: () async {
                        var picked_date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2100));

                        if (picked_date != null && picked_date != date) {
                          setState(() {
                            date = picked_date;
                          });
                        }
                      })),
              ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(15, 30, 0, 0),
                  title: GestureDetector(
                    child: Text(
                      DateFormat('HH:mm').format(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          start.hour,
                          start.minute)),
                      style: TextStyle(fontSize: 35),
                    ),
                    onTap: () async {
                      var time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: start.hour, minute: start.minute));
                      if (time != null && time != start) {
                        setState(() {
                          start = time;
                        });
                      }
                    },
                  )),
              ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(15, 30, 0, 0),
                  title: GestureDetector(
                    child: Text(
                      DateFormat('HH:mm').format(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          start.hour,
                          start.minute)),
                      style: TextStyle(fontSize: 35),
                    ),
                    onTap: () async {
                      var time = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay(hour: end.hour, minute: end.minute));
                      if (time != null && time != end) {
                        setState(() {
                          end = time;
                        });
                      }
                    },
                  ))
            ]),
          )),
    );
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

var _selectedAppointment;
void calendarTapped(CalendarTapDetails calendarTapDetails) {
  if (calendarTapDetails.targetElement == CalendarElement.agenda ||
      calendarTapDetails.targetElement == CalendarElement.appointment) {
    final Appointment appointment = calendarTapDetails.appointments![0];
    _selectedAppointment = appointment;
  }
}

List<Appointment> getEventsSaved(SharedPreferences prefs) {
  List<String>? save = prefs.getStringList("events");
  List<Appointment> events = <Appointment>[];
  bool tdone = false;
  String value = "";
  int y = 0;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String subject = "";
  if (save != null && save.length != null && save.isNotEmpty) {
    for (int i = 0; i < save.length; i++) {
      String x = save[i];
      y = 0;
      value = "";
      for (int i = 0; i < x.length; i++) {
        if (x[i] != ";") {
          if (y == 1 || y == 2) {
            if (x[i] == " " && tdone == false) {
              value += "T";
              tdone = true;
            } else if (x[i] == " " && tdone == true) {
            } else if (x[i] == "–") {
            } else {
              value += x[i];
            }
          } else {
            value += x[i];
          }
        } else {
          switch (y) {
            case 1:
              {
                start = DateTime.parse(value);
                y = 2;
              }
              break;
            case 2:
              {
                end = DateTime.parse(value);
                y = 0;
              }
              break;
            case 0:
              {
                subject = value;
                y = 1;
              }
              break;
          }
          value = "";
          tdone = false;
        }
      }
      Appointment z = Appointment(
        startTime: start,
        endTime: end,
        subject: subject,
      );
      events.add(z);
    }
  }
  return events;
}
