class Election {
  final String id;

  // From Election Declaration (Step 1)
  final String category;
  final String subType;

  // From Step 1 – Location
  final String state;
  final String district;

  // From Step 2
  final String name;
  final String electionCode;
  final String remarks;

  // From Step 3 – Dates
  final DateTime notificationDate;
  final DateTime pollDate;
  final DateTime? countingDate;
  final DateTime? resultDate;

  // From Step 4 – Stats
  final int? totalSeats;
  final int? totalVoters;
  final int voterTurnout;

  // System
  final String status; // upcoming | ongoing | past
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
    this.remarks = '',
    required this.icon,
  });
}