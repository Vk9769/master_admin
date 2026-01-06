class Election {
  final String id;
  final String category;
  final String subType;
  final String state;
  final String district;
  final String name;
  final String electionCode;
  final DateTime notificationDate;
  final DateTime pollDate;
  final DateTime? countingDate;
  final DateTime? resultDate;
  final int? totalSeats;
  final int? totalVoters;
  final int voterTurnout;
  final String status;
  final String remarks;
  final String icon;

  Election({
    required this.id,
    required this.category,
    required this.subType,
    required this.state,
    required this.district,
    required this.name,
    required this.electionCode,
    required this.notificationDate,
    required this.pollDate,
    this.countingDate,
    this.resultDate,
    this.totalSeats,
    this.totalVoters,
    this.voterTurnout = 0,
    required this.status,
    required this.remarks,
    this.icon = '🗳️',
  });

  // ✅ ADD THIS FACTORY
  factory Election.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return Election(
      id: json['id'].toString(),

      category: json['election_category'] ?? 'N/A',
      subType: json['election_type'] ?? 'N/A',

      state: json['state'] ?? '',
      district: json['district'] ?? json['constituency'] ?? '',

      name: json['election_name'] ?? 'Unnamed Election',
      electionCode: json['election_code'] ?? 'N/A',

      notificationDate:
      parseDate(json['notification_date']) ?? DateTime.now(),

      pollDate:
      parseDate(json['poll_date']) ?? DateTime.now(),

      countingDate: parseDate(json['counting_date']),
      resultDate: parseDate(json['result_date']),

      totalSeats: json['total_seats'],
      totalVoters: json['total_voters'],

      voterTurnout: json['voter_turnout'] ?? 0,

      // 👇 map backend status properly
      status: _mapStatus(json['status']),

      remarks: json['description'] ?? '',
      icon: '🗳️',
    );
  }
  static String _mapStatus(String? status) {
    switch (status) {
      case 'active':
        return 'ongoing';
      case 'completed':
        return 'past';
      case 'upcoming':
        return 'upcoming';
      default:
        return 'upcoming';
    }
  }

}
