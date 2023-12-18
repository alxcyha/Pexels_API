import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(
        useMaterial3: false,
      ).copyWith(
        scaffoldBackgroundColor: Colors.pink[50],
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),

    );
  }
}

class Home extends StatefulWidget {

  @override
  State<Home> createState() => HomePage();
}

class HomePage extends State<Home> {
  final String apiKey = 'T5xGfsc6w0THa9FBF6ciS4DEr06U1mlNMIWCAN6ibtY73IR7WwpbA4nj';
  List<dynamic> photos = [];
  int page = 1;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    getPhotos();
  }

  //to get photos using API
  getPhotos() async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
    var url = Uri.parse('https://api.pexels.com/v1/curated?per_page=80');
    var headers = {'Authorization': apiKey};

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        photos = json.decode(response.body)['photos'];
      });
    } else {
      print('Failed to load photos. Status code: ${response.statusCode}');
    }
  }

  //to load more pictures from API
  loadMore() async {

    setState(() {
      page = page + 1;
    });

    final url = Uri.parse('https://api.pexels.com/v1/curated?per_page=80/page=${page.toString()}');
    var headers = {'Authorization': apiKey};

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {

        photos.addAll(json.decode(response.body)['photos']);
      });
    } else {
      print('Failed to load photos. Status code: ${response.statusCode}');
    }

    print("Load More");

  }

  //First page of the app, photos posted in gridview
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ElevatedButton(
        onPressed: loadMore,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
        ),
        child: Text("Load More", style: TextStyle(color: Colors.pink[200])),
      ),

      appBar: AppBar(
        title: Text("Pexels Photos"),
        backgroundColor: Colors.pink[200],
        centerTitle: true,

      ),
      body: GridView.builder(
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              //on tap on photo navigate to next page posting bigger img of photo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Photo(
                    photoUrl: photos[index]['src']['large'],
                  ),
                ),
              );
            },

            //design of first page
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photos[index]['src']['tiny']),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(3.5),
              ),
            ),
          );
        },
      ),
    );
  }
}

//will display on tap
class Photo extends StatelessWidget {
  final String photoUrl;
  Photo({required this.photoUrl});

  get isLoading => null;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: Text("Photo"),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading ? CircularProgressIndicator():Image.network(
          photoUrl,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress==null) {
              return child;
            } else {
              return Center(
                child:CircularProgressIndicator(

                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                )
              );
            }
          },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            print('Error loading image: $error');
            print('StackTrace: $stackTrace');
            return const Center(
              child: Text('Error loading image'),
            );
          },
        ),
      ),
    );
  }
}