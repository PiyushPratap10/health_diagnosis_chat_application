import 'package:flutter/material.dart';
import 'package:healthwise_ai/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: const Color.fromARGB(255, 39, 39, 39)),
        ),
        iconTheme: const IconThemeData(color: const Color.fromARGB(255, 39, 39, 39)),
        backgroundColor: Color.fromARGB(255, 255, 223, 0),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: Text("No user data available"))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth > 600;
                return Center(
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: isLargeScreen ? 600 : double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Name: ${user.name}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 39, 39, 39),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Email: ${user.email}",
                            style: const TextStyle(
                              color: const Color.fromARGB(255, 39, 39, 39),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Age: ${user.age != null ? user.age.toString() : 'Not specified'}",
                            style: const TextStyle(
                              color: const Color.fromARGB(255, 39, 39, 39),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Gender: ${user.gender ?? 'Not specified'}",
                            style: const TextStyle(
                              color: const Color.fromARGB(255, 39, 39, 39),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to Update Profile Screen
                                  Navigator.pushNamed(context, "/update");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 39, 39, 39),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Update Profile",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  userProvider.clearUser();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Log Out",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
