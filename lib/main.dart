
import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart' show AndroidConfiguration, FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:flutter/material.dart';
import 'background_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

  runApp( const MyApp());
}


class MyApp extends StatefulWidget {

  const MyApp({Key? key,}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        appBar: AppBar(
          title: const Text("Voice Bot"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //for listen Continuous change in foreground we will be using Stream builder
              StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on('update'),
                  builder: (context,snapshot){
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final data = snapshot.data!;
                String? lastMessage = data["last_message"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(lastMessage ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: const Text("Foreground Mode",style: TextStyle(
                        color: Colors.white
                      ),)),
                  onTap: () {
                    FlutterBackgroundService().invoke("setAsForeground");

                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: const Text("Background Mode",style: TextStyle(
                          color: Colors.white
                      ),)),
                  onTap: () {
                    print('start');
                    FlutterBackgroundService().invoke("setAsBackground");

                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Text(text,style: const TextStyle(
                        color: Colors.white
                    ),),
                  ),
                  onTap: () async {
                    final service=FlutterBackgroundService();
                   // final service = widget.appStateService.service;
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    } else {
                      service.startService();
                    }

                    if (!isRunning) {
                      text = 'Stop Service';
                    } else {
                      text = 'Start Service';
                    }
                    setState(() {});
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
