// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ems/pages/event_details_page.dart';
import 'package:ems/pages/login_page.dart';
import 'dart:async';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer _timer;
  String userRole = 'normal_user';

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _autoSlideEvents();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<DocumentReference<Object?>> addEvent(String title, String description,
      DateTime date, String address, String price) async {
    return await eventsCollection.add({
      'title': title,
      'description': description,
      'date': date,
      'address': address,
      'createdBy': _auth.currentUser!.uid,
      "price": "Free",
      'attendees': [],
    });
  }

   Future<void> _getUserRole() async {
    final userId = FirebaseAuth.instance.currentUser!.uid; 
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        userRole = userDoc['role']; 
       
      });
    }
  }

  Future<void> attendEvent(String eventId) async {
    final eventDoc = eventsCollection.doc(eventId);
    eventDoc.update({
      'attendees': FieldValue.arrayUnion([_auth.currentUser!.uid])
    });
  }

  void _autoSlideEvents() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/imgs/logo.png", width: 80),
            Text(
              'Event Hub',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple[800],
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[100]!, Colors.blue[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
  stream: eventsCollection.snapshots(),
  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = snapshot.data!.docs;

   
    if (events.isEmpty) {
      return const Center(child: Text('No events to display.', style: TextStyle(fontSize: 18)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "UPCOMING EVENTS",
          style: GoogleFonts.robotoMono(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Material(
                borderRadius: BorderRadius.circular(15),
                shadowColor: Colors.black54,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[300]!,
                        const Color.fromARGB(255, 92, 39, 176),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                          const Icon(
                            Icons.event_note,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                            ],
                          ),
                          
                          Text(
                        event['date'].toDate().toString().split(' ')[0],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                         " ${event['description']}",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      
                     
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue[100],
                              foregroundColor: Colors.deepPurple[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            ),
                            child: const Text('More Details'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsPage(event: event),
                                ),
                              );
                            },
                          ),
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "ALL EVENTS",
          style: GoogleFonts.robotoMono(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1; 
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2; 
              } else {
                crossAxisCount = 3; 
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                    child: Card(
                      color: const Color.fromARGB(131, 92, 39, 176),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Session1682407315.svg/640px-Session1682407315.svg.png', // Replace with actual image URL
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        event['title'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.description,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        event['description'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_note,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      event['date']
                                          .toDate()
                                          .toString()
                                          .split(' ')[0],
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_city,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        event['address'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  },
),
      ),
      floatingActionButton: userRole == 'promoter' 
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => CreateEventDialog(onSubmit: addEvent),
              ),
              backgroundColor: Colors.deepPurple[700],
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
              label: const Text(
                'Create Event',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null, 
    );
  }
}

class CreateEventDialog extends StatefulWidget {
  final Future<DocumentReference<Object?>> Function(
      String, String, DateTime, String, String) onSubmit;

  const CreateEventDialog({super.key, required this.onSubmit});

  @override
  _CreateEventDialogState createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Event title is required';
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Text(
                  "Date: ${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(color: Colors.black),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked; 
                      });
                    }
                  },
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                titleController.text,
                descriptionController.text,
                selectedDate,
                addressController.text,
                priceController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
