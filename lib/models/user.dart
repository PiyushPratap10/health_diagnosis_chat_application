
class User {
  String? userId;
  String name;
  String email;
  String password;
  int? age;
  String? gender;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.userId,
    this.age,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']??"",
      name: json['name']??"",
      email: json['email']??"",
      password: json['password']??"",
      age: json['age'],
      gender: json['gender']??"",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
    };
  }
}
