import 'dart:html';

class User{
  String id;
  final String username;
  final String email;
  final String phone;
  final int points;
  final String email_verified;

  User({
    this.id = '',
    required this.phone,
    required this.email,
    required this.email_verified,
    required this.points,
    required this.username
});
  Map<String, dynamic> toJson() =>{
    'id' : id,
    'username' : username,
    'email' : email,
    'phone_number' : phone,
    'points' : points,
    'email_verification' : email_verified,
  };

  static User fromJson(Map<String,dynamic>json) => User(
      phone: json['phone_number'],
      email: json['email'],
      email_verified: json['email_verification'],
      points: json['points'],
      username: json['username']);
}