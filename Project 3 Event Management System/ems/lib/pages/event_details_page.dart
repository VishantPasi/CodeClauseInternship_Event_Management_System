// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetailsPage extends StatelessWidget {
  final DocumentSnapshot event;

  const EventDetailsPage({super.key, required this.event});

  Future<void> _attendEvent(BuildContext context) async {
    
    try {
     
      String userId = "currentUserId"; 

    
      await FirebaseFirestore.instance.collection('events').doc(event.id).update({
        'attendees': FieldValue.arrayUnion([userId]),
      });

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are now attending this event! and event details will be mailed to you shortly'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error attending event: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventDate = (event['date'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['title'],
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Description',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              event['description'],
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Date of Event',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${eventDate.toLocal()}'.split(' ')[0],
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Address',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              event['address'],
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Price',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${event['price']}",
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Number of Attendees',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              event['attendees'] != null
                  ? '${event['attendees'].length} attendees'
                  : 'No attendees yet',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Add Attend Button
            Center(
              child: ElevatedButton(
                onPressed: () {_attendEvent(context);
                
                Navigator.pop(context);},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[800],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Attend',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
