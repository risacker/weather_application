import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int temperature;
  String location = "London";
  int woeid = 44418;
  String weather = "Clear";
  String abbreviation='';
  String errorMessage = '';
  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchlocation();
  }
  void fetchSearch(String input) async {
    try {
      var searchResults = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResults.body)[0];
      setState(() {
        location = result["title"];
        woeid = result["woeid"];
      });
    }
    catch (error) {
      setState(() {
        errorMessage = 'Sorry!!Location not found';
      });
    }
  }
    void fetchlocation() async {
      var locationResult = await http.get((Uri.parse(locationApiUrl + woeid.toString())));
      var result = json.decode(locationResult.body);
      var consolatedweather = result["consolidated_weather"];
      var data = consolatedweather[0];

      setState(() {
        temperature = data["the_temp"].round();
        weather = data["weather_state_name"];
        abbreviation = data["weather_state_abbr"];
      });
    }
    void onTextFieldSubmitted(String input) async{
      fetchSearch(input);
      fetchlocation();
    }


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'),
                fit: BoxFit.cover
            ),
          ),
          child: temperature == null
              ?Center(child: CircularProgressIndicator())
              :Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Center(
                      child: Image.network(
                        'https://www.metaweather.com/static/img/weather/png/'+abbreviation+'.png',
                        width: 100,
                      ),
                    ),
                    Center(
                      child: Text(
                        temperature.toString() + 'C',
                        style: TextStyle(color: Colors.white, fontSize: 60,),
                      ),
                    ),
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.white, fontSize: 60,),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 25,),
                        decoration: InputDecoration(
                          hintText: 'Search other location',
                          hintStyle: TextStyle(color: Colors.white,
                            fontSize: 20,),
                          prefixIcon: Icon(Icons.search, color: Colors.white,),

                        ),
                      ),
                    ),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
