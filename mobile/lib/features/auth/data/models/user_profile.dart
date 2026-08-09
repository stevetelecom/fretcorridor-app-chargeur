class UserProfile {
  UserProfile({
    required this.id,
    required this.accountType,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.accountLevel,
  });

  final String id;
  final String accountType;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String accountLevel;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        accountType: json['accountType'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber'],
        accountLevel: json['accountLevel'],
      );
}
