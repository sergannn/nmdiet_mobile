class StoryBlock {
  const StoryBlock({
    required this.kind,
    required this.text,
    this.title = '',
    this.value = '',
  });
  final String kind, text, title, value;
}

class StorySection {
  const StorySection({
    required this.title,
    required this.eyebrow,
    required this.blocks,
    required this.images,
  });
  final String title, eyebrow;
  final List<StoryBlock> blocks;
  final List<String> images;
}

class ProductStory {
  const ProductStory({
    this.subtitle = '',
    this.concept = '',
    this.sections = const [],
  });
  final String subtitle, concept;
  final List<StorySection> sections;
}

abstract interface class ProductStoryRepository {
  Future<ProductStory> product(String slug);
}

class EmptyProductStories implements ProductStoryRepository {
  const EmptyProductStories();
  @override
  Future<ProductStory> product(String slug) async => const ProductStory();
}
