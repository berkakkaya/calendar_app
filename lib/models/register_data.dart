class RegisterData {
  String? name;
  String? surname;
  String? username;
  String? email;
  String? password;
  int? tcIdentityNumber;
  String? phone;
  String? address;

  bool get allDataProvided {
    return ![
      name,
      surname,
      username,
      email,
      password,
      tcIdentityNumber,
      phone,
      address
    ].contains(null);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};

    data["name"] = name == "" ? null : name;
    data["surname"] = surname == "" ? null : surname;
    data["username"] = username == "" ? null : username;
    data["email"] = email == "" ? null : email;
    data["password"] = password == "" ? null : password;
    data["tcIdentityNumber"] = tcIdentityNumber;
    data["phone"] = phone == "" ? null : phone;
    data["address"] = address == "" ? null : address;

    return data;
  }
}
