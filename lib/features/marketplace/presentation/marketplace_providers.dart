import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/marketplace_repository.dart';
import '../../../models/marketplace_item.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository(FirebaseFirestore.instance);
});

final marketplaceListProvider = StreamProvider<List<MarketplaceItem>>((ref) {
  return ref.watch(marketplaceRepositoryProvider).watchItems();
});
