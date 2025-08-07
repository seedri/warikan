import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:isar/isar.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/event_normal.dart';
import 'package:warikan/pages/event_page/widgets/list_tile_keisha.dart';
import 'package:warikan/pages/event_page/widgets/list_tile_normal.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.isar});
  final Isar isar;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<List<dynamic>> _eventsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = _getAllEvents();
    });
  }

  Future<List<dynamic>> _getAllEvents() async {
    final eventNormals = await widget.isar.eventNormals.where().findAll();
    final eventKeishas = await widget.isar.eventKeishas.where().findAll();
    final events = [...eventNormals, ...eventKeishas];
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('イベントがありません'));
          } else {
            final events = snapshot.data!;
            return AnimationLimiter(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  if (event is EventNormal) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ListTileNormal(
                            event: event,
                            isar: widget.isar,
                            onRefresh: _loadEvents, // 再読み込み用のコールバック
                          ),
                        ),
                      ),
                    );
                  } else if (event is EventKeisha) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ListTileKeisha(
                            event: event,
                            isar: widget.isar,
                            onRefresh: _loadEvents,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
