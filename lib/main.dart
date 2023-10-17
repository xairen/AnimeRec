import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Recommendation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ThemeData().colorScheme.copyWith(
          secondary: Colors.amber,
        ),
        fontFamily: 'Roboto',
      ),
      home: AnimeRecommendationPage(),
    );
  }
}

class AnimeRecommendationPage extends StatefulWidget {
  @override
  _AnimeRecommendationPageState createState() => _AnimeRecommendationPageState();
}

class IconStars extends StatelessWidget {
  final double rating;

  IconStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (rating >= i * 2) {
        stars.add(Icon(Icons.star, color: Colors.yellow));
      } else if (rating > (i - 1) * 2) {
        stars.add(Icon(Icons.star_half, color: Colors.yellow));
      } else {
        stars.add(Icon(Icons.star_border));
      }
    }

    return Row(children: stars);
  }
}


class _AnimeRecommendationPageState extends State<AnimeRecommendationPage> {
  List<dynamic> animeList = [];
  String? selectedGenre;
  String? selectedSize;
  List<dynamic> recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadAnimeData();
  }

  _loadAnimeData() async {
    final jsonString = await rootBundle.loadString('assets/anime_dataset.json');
    final jsonData = json.decode(jsonString) as List;
    setState(() {
      animeList = jsonData;
    });
  }

  _getRecommendations() {
    final filtered = animeList.where((anime) =>
    anime['genre'] != null && 
    anime['genre'].contains(selectedGenre!) && 
    anime['size'] == selectedSize).take(10).toList();
    setState(() {
      recommendations = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anime Recommendations')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/WallpaperDog-20542425.jpg'), // Fixed the typo here
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: selectedGenre,
                hint: Text('Select Genre'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGenre = newValue;
                  });
                },
                items: ['Action', 'Adventure', 'Comedy', 'Romance', 'Horror', 'Supernatural']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedSize,
                hint: Text('Select Size'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSize = newValue;
                  });
                },
                items: ['Small', 'Medium', 'Large', 'Huge']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.search),
                onPressed: _getRecommendations,
                label: Text('Get Recommendations'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: ListView.builder(
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final anime = recommendations[index];
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.secondary, // Fixed the color here
                            child: Text(recommendations[index]['name'][0]),
                          ),
                          title: Text(recommendations[index]['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text("Genre: ${anime['genre']}"),
                              SizedBox(height: 4),
                              Row(children: [
                                IconStars(rating: anime['rating']),
                                SizedBox(width: 4),
                                Text("${anime['rating']/2}/5")
                              ],)
                            ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
