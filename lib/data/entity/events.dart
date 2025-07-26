class Events {
  final String id;
  final String name;
  final String? imageUrl;
  final String? date;
  final String? time;
  final String? venueName;
  final String? city;
  final String? organizer;
  final String? segment;
  final String? genre;

  Events({
    required this.id, required this.name, required this.imageUrl,
    required this.date, required this.time, required this.venueName, required this.city,
    required this.organizer, required this.segment, required this.genre
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    final venue = json['_embedded']?['venues']?[0];
    final organizer = json['_embedded']?['attractions']?[0]?['name'];
    final classification = json['classifications']?[0];


    return Events(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: (json['images'] != null && json['images'].isNotEmpty) ? json['images'][0]['url'] : null,
      date: json['dates']?['start']?['localDate'],
      time: json['dates']?['start']?['localTime'],
      venueName: venue?['name'],
      city: venue?['city']?['name'],
      organizer: organizer,
      segment: classification?['segment']?['name'],
      genre: classification?['genre']?['name'],
    );
  }
}