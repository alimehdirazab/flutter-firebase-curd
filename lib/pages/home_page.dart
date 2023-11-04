import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore object
  FirestoreService firestoreService = FirestoreService();

  TextEditingController noteController = TextEditingController();
  // open a dialog box to add a note
  void openNoteBox({String? docId, String? note}) {
    (docId == null)
        ? noteController.clear()
        : setState(() {
            noteController.text = note!;
          });
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text((docId == null) ? 'ADD NOTE' : 'UPDATE NOTE'),
              content: TextField(
                minLines: 1,
                maxLines: 5,
                controller: noteController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                      width: 5,
                      color: Colors.black,
                      style: BorderStyle.solid,
                    )),
                    hintText: (docId == null)
                        ? "Write Your Note"
                        : "Write Updated Note"),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // add note
                    if (docId == null) {
                      firestoreService.addNote(noteController.text);
                    }
                    //update note
                    else {
                      firestoreService.updateNote(docId, noteController.text);
                    }

                    // clear text controller
                    noteController.clear();

                    // close dialogBox
                    Navigator.pop(context);
                  },
                  child: Text((docId == null) ? "Add Note" : "Update Note"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 219, 219),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 51, 51),
        title: const Text("Notes App FireBase"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have data get all docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each  individual docs
                DocumentSnapshot document = notesList[index];
                String docId = document.id;

                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                Timestamp noteTime = data['timestamp'];

                // Convert the Firebase timestamp to a Dart DateTime
                DateTime dateTime = noteTime.toDate();

                // Define the date and time format you want
                String formattedDate =
                    DateFormat('dd-MM-yyyy HH:mm').format(dateTime);

                // display in a list tile
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                        title: Text(noteText),
                        subtitle: Text(formattedDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // update button
                            IconButton(
                              onPressed: () =>
                                  openNoteBox(docId: docId, note: noteText),
                              icon: const Icon(Icons.edit),
                            ),
                            //delete button
                            IconButton(
                              onPressed: () =>
                                  firestoreService.deleteNote(docId),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        )),
                  ),
                );
              },
            );
          }
          // if there is no note
          else {
            return const Center(child: Text('No Notes...'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Colors.black54,
        child: const Icon(Icons.add),
      ),
    );
  }
}
