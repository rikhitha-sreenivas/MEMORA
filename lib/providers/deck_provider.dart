import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deck_model.dart';

class DeckProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<DeckModel> _decks = [];

  List<DeckModel> get decks => _decks;

  Future<void> loadDecks() async {
    final snapshot =
        await _firestore.collection('decks').get();

    _decks =
        snapshot.docs
            .map(
              (doc) => DeckModel.fromFirestore(
                doc.id,
                doc.data(),
              ),
            )
            .toList();

    notifyListeners();
  }

  Future<void> addDeck(
    String title,
  ) async {
    await _firestore.collection('decks').add({
      'title': title,
      'description': '',
      'cardCount': 0,
    });

    await loadDecks();
  }

  Future<void> deleteDeck(
    String id,
  ) async {
    await _firestore
        .collection('decks')
        .doc(id)
        .delete();

    await loadDecks();
  }
}