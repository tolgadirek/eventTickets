class EventDetail {
  final String id;
  final String name;
  final String? description;
  final String? date;
  final String? time;
  final String? venue;
  final String? city;
  final String? country;
  final String? organizer;
  final String? imageUrl;
  final String? ticketUrl;
  final double? latitude;
  final double? longitude;
  final String? salesStart;
  final String? salesEnd;
  final String? ticketLimitInfo;
  final String? segment;
  final String? genre;

  EventDetail({
    required this.id, required this.name, required this.description, required this.date,
    required this.time, required this.venue, required this.city, required this.country,
    required this.organizer, required this.imageUrl, required this.ticketUrl,
    required this.latitude, required this.longitude, required this.salesStart, required this.salesEnd,
    required this.ticketLimitInfo, required this.segment, required this.genre
  });

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    final venue = json['_embedded']?['venues']?[0];
    final location = venue?['location'];
    final images = json['images'];
    final organizer = json['_embedded']?['attractions']?[0]?['name'];
    final sales = json['sales']?['public'];
    final ticketLimit = json['ticketLimit'];
    final classification = json['classifications']?[0];

    return EventDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['info'] ?? json['pleaseNote'] ?? json["description"],
      date: json['dates']?['start']?['localDate'],
      time: json['dates']?['start']?['localTime'],
      venue: venue?['name'],
      city: venue?['city']?['name'],
      country: venue?['country']?['name'],
      organizer: organizer,
      imageUrl: (images != null && images.isNotEmpty) ? images[0]['url'] : null,
      ticketUrl: json['url'],
      latitude: location?['latitude'] != null ? double.tryParse(location['latitude']) : null,
      longitude: location?['longitude'] != null ? double.tryParse(location['longitude']) : null,
      salesStart: sales?['startDateTime'],
      salesEnd: sales?['endDateTime'],
      ticketLimitInfo: ticketLimit?['info'],
      segment: classification?['segment']?['name'],
      genre: classification?['genre']?['name'],
    );
  }
}