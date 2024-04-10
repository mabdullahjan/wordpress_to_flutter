import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Map<String, dynamic>> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost(widget.postId);
  }

  Future<Map<String, dynamic>> fetchPost(int postId) async {
    final response = await http.get(
        Uri.parse('https://yoursite.com/wp-json/wp/v2/posts/$postId?_embed'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Widget _buildContent(String htmlContent) {
    dom.Document document = htmlParser.parse(htmlContent);

    List<Widget> children = [];

    for (var node in document.body!.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        children.add(Text(
          node.text!,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ));
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        var element = node as dom.Element;
        if (element.localName == 'p') {
          children.add(Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              element.text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ));
        } else if (element.localName == 'h1' || element.localName == 'h2') {
          children.add(Container(
            margin: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              element.text,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ));
        } else if (element.localName == 'img') {
          String imageUrl = element.attributes['src'] ?? '';
          if (imageUrl.isNotEmpty) {
            children.add(Image.network(
              imageUrl,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ));
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: post,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> postData = snapshot.data!;
            return ListView(
              children: [
                if (postData['_embedded'] != null &&
                    postData['_embedded']['wp:featuredmedia'] != null)
                  Image.network(
                    postData['_embedded']['wp:featuredmedia'][0]['source_url'],
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    postData['title']['rendered'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildContent(postData['content']['rendered']),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
