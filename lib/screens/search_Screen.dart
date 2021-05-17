import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/DataHandler/appData.dart';
import 'package:uber_clone/configMaps.dart';
import 'package:uber_clone/helper/api.dart';
import 'package:uber_clone/models/address.dart';
import 'package:uber_clone/models/placePrediction.dart';
import 'package:uber_clone/widget/Divider.dart';
import 'package:uber_clone/widget/progressdialog.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController txtPickUpAddress = TextEditingController();
  TextEditingController txtDestinationAddress = TextEditingController();
  List<PlacePrediction> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    var pickUpaddress = Provider.of<AppData>(context).pickUpLocation.placeName;
    txtPickUpAddress.text = pickUpaddress;

    return Scaffold(
      body: SingleChildScrollView(
              child: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 6.0,
                    offset: Offset(0.7, 0.7)),
              ]),
              child: Padding(
                padding: EdgeInsets.only(left:25.0, top: 40.0, right: 25.0, bottom: 20.0),
                child: Column(children: [
                  SizedBox(height: 5.0,),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text('Set Drop Off', style: TextStyle(fontSize: 18.0),),
                      )
                    ],
                  ),
                  SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Image.asset("assets/images/pickicon.png", height: 16.0, width: 16.0,),
                      SizedBox(width: 18.0,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: txtPickUpAddress,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  Row(
                    children: [
                      Image.asset("assets/images/desticon.png", height: 16.0, width: 16.0,),
                      SizedBox(width: 18.0,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val){
                                findPlace(val);
                              },
                              controller: txtDestinationAddress,
                              decoration: InputDecoration(
                                hintText: "Where To ?",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      
                      ),
                    ],
                  )
                ],),
              ),
            ),
            SizedBox(height: 10.0,),
          (placePredictionList.length > 0) ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListView.separated(
              padding: EdgeInsets.all(0.0),
              itemBuilder: (context, index){
                return PredictionTile(placePrediction: placePredictionList[index],);
              }, 
              separatorBuilder: (BuildContext context,  index) => DividerWidget(),
              itemCount: placePredictionList.length,
              shrinkWrap: true,
              physics:ClampingScrollPhysics()),
          ):Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async{
    if(placeName.length > 1){
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapkey&sessiontoken=1234567890&components=country:ng";
    
      var res = await Api.getUrl(autoCompleteUrl);
      if(res == "failed"){
        return;
      }
       if(res["status"] == "OK"){
         var prediction = res['predictions'];
         var placesList = (prediction as List).map((e) => PlacePrediction.fromJson(e)).toList();
         setState(() {
           placePredictionList = placesList;
         });
       }
      }
    }
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;
  PredictionTile({Key key, this.placePrediction}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: (){
        getAddressDetails(placePrediction.placeId, context);
      },
          child: Container(
          child: Column(
            children: [
               SizedBox(width: 10.0,),
              Row(
                children: [
                  Icon(Icons.add_location),
                  SizedBox(width: 14.0,),
                  Expanded(
                                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          SizedBox(height: 8.0,),
                        Text(placePrediction.mainText, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0)),
                         SizedBox(height: 2.0,),
                        Text(placePrediction.secondaryText, overflow: TextOverflow.ellipsis,  style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                     SizedBox(height: 8.0,),
                    ],),
                  )
                ],
              ),
               SizedBox(width: 10.0,),
            ],
          ),
      ),
    );
  }
  void getAddressDetails(String placeId, context) async{

    showDialog(context: context,
      builder: (BuildContext context)=> ProgressDialog(message: "Setting Dropoff Please Wait..",)
    );
    String placeAddressUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";
    var res = await Api.getUrl(placeAddressUrl);
    Navigator.pop(context);
    if(res == "failed"){
      return;
    }
    
    if(res["status"] == "OK"){
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

  Provider.of<AppData>(context, listen: false).updateDropOfflocation(address);
  print("this is the drop off location");
  print(address.placeName);
  Navigator.pop(context, "obtainDirection");
  // Navigator.pop(context, "obtainDirection");
    }
  }
}