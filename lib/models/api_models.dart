// API Models for RUZ Timetable

class SearchResult {
  final int type; // 1 = group, 2 = lecturer
  final String id;
  final String name;
  final String description;

  SearchResult({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type'] ?? 0,
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Discipline {
  final int id;
  final String name;

  Discipline({required this.id, required this.name});

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Lecturer {
  final int id;
  final String name;
  final String short;

  Lecturer({required this.id, required this.name, required this.short});

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      short: json['short'] ?? '',
    );
  }
}

class FilterOptions {
  final List<Discipline> disciplines;
  final List<Location> locations;
  final List<Lecturer> eblans;

  FilterOptions({
    required this.disciplines,
    required this.locations,
    required this.eblans,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      disciplines: (json['disciplines'] as List<dynamic>?)
          ?.map((e) => Discipline.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      eblans: (json['eblans'] as List<dynamic>?)
          ?.map((e) => Lecturer.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class EblanInfo {
  final int eblanId;
  final String eblanName;
  final String eblanNameShort;

  EblanInfo({
    required this.eblanId,
    required this.eblanName,
    required this.eblanNameShort,
  });

  factory EblanInfo.fromJson(Map<String, dynamic> json) {
    return EblanInfo(
      eblanId: json['eblanId'] ?? 0,
      eblanName: json['eblanName'] ?? '',
      eblanNameShort: json['eblanNameShort'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eblanId': eblanId,
      'eblanName': eblanName,
      'eblanNameShort': eblanNameShort,
    };
  }
}

class LocationInfo {
  final int locationId;
  final String locationName;
  final String cabinet;

  LocationInfo({
    required this.locationId,
    required this.locationName,
    required this.cabinet,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      locationId: json['locationId'] ?? 0,
      locationName: json['locationName'] ?? '',
      cabinet: json['cabinet']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'cabinet': cabinet,
    };
  }
}

class DisciplineInfo {
  final int disciplineId;
  final String disciplineName;

  DisciplineInfo({
    required this.disciplineId,
    required this.disciplineName,
  });

  factory DisciplineInfo.fromJson(Map<String, dynamic> json) {
    return DisciplineInfo(
      disciplineId: json['disciplineId'] ?? 0,
      disciplineName: json['DisciplineName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disciplineId': disciplineId,
      'DisciplineName': disciplineName,
    };
  }
}

class Lesson {
  final String start;
  final String end;
  final bool isLecture;
  final EblanInfo eblanInfo;
  final LocationInfo locationInfo;
  final DisciplineInfo disciplineInfo;

  Lesson({
    required this.start,
    required this.end,
    required this.isLecture,
    required this.eblanInfo,
    required this.locationInfo,
    required this.disciplineInfo,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      isLecture: json['isLecture'] ?? false,
      eblanInfo: EblanInfo.fromJson(json['eblanInfo'] ?? {}),
      locationInfo: LocationInfo.fromJson(json['locationInfo'] ?? {}),
      disciplineInfo: DisciplineInfo.fromJson(json['disciplineInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'isLecture': isLecture,
      'eblanInfo': eblanInfo.toJson(),
      'locationInfo': locationInfo.toJson(),
      'disciplineInfo': disciplineInfo.toJson(),
    };
  }

  DateTime get startDateTime {
    try {
      return DateTime.parse(start);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime get endDateTime {
    try {
      return DateTime.parse(end);
    } catch (e) {
      return DateTime.now();
    }
  }
}
