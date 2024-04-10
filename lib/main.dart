import 'package:wordpresstoflutter/postdetails.dart';
import 'package:wordpresstoflutter/wordpressapi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordPress API Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WordPressAPI api = WordPressAPI();
  late Future<List<Map<String, dynamic>>> categories;
  late Future<List<Map<String, dynamic>>> posts;
  late List<Map<String, dynamic>> allCategories = [];
  late String selectedCategory =
      'All'; // Initialize selectedCategory with 'All'

  @override
  void initState() {
    super.initState();
    categories = api.getAllCategories();
    posts = api.getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WordPress API Demo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                allCategories = snapshot.data!;
                List<String> categoryNames = ['All'];
                categoryNames
                    .addAll(allCategories.map((category) => category['name']));

                // Check if selectedCategory is in categoryNames, if not, set it to 'All'
                if (!categoryNames.contains(selectedCategory)) {
                  selectedCategory = 'All';
                }

                return DropdownButton<String>(
                  value: selectedCategory,
                  items: categoryNames.map((String categoryName) {
                    return DropdownMenuItem<String>(
                      value: categoryName,
                      child: Text(categoryName),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value ??
                          'All'; // Use null safety operator to avoid null value
                    });
                  },
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: posts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map<String, dynamic>> data = snapshot.data!;
                  if (selectedCategory != 'All') {
                    int categoryId = allCategories.firstWhere((category) =>
                        category['name'] == selectedCategory)['id'];
                    data = data.where((post) {
                      List<dynamic> categories = post['categories'];
                      return categories.contains(categoryId);
                    }).toList();
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index]['title']['rendered']),
                        subtitle: Text(data[index]['excerpt']['rendered']),
                        leading: data[index]['featured_media'] != 0
                            ? Image.network(
                                data[index]['_embedded']['wp:featuredmedia'][0]
                                    ['source_url'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: data[index]['id'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
