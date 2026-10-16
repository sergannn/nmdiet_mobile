import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/product_story.dart';

class BundledProductStories implements ProductStoryRepository {
  BundledProductStories(this.bundle);
  final AssetBundle bundle;
  Future<Map<String, dynamic>>? _content;
  @override
  Future<ProductStory> product(String slug) async {
    final all = await (_content ??= bundle
        .loadString('assets/content/product_stories.json')
        .then((s) => jsonDecode(s) as Map<String, dynamic>));
    final data = all[slug] as Map<String, dynamic>?;
    if (data == null) return const ProductStory();
    return ProductStory(
      subtitle: data['subtitle'] as String,
      concept: data['concept'] as String,
      sections: [
        for (final s in data['sections'] as List)
          StorySection(
            title: s['title'] as String,
            eyebrow: s['eyebrow'] as String,
            blocks: [
              for (final b in s['blocks'] as List)
                StoryBlock(
                  kind: b['kind'] as String,
                  text: b['text'] as String? ?? '',
                  title: b['title'] as String? ?? '',
                  value: b['value'] as String? ?? '',
                ),
            ],
            images: [for (final i in s['images'] as List) i['asset'] as String],
          ),
      ],
    );
  }
}
