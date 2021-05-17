import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/DataHandler/appData.dart';
import 'package:uber_clone/configMaps.dart';
import 'package:uber_clone/helper/api.dart';
import 'package:uber_clone/models/address.dart';
import 'package:uber_clone/models/allUsers.dart';
import 'package:uber_clone/models/directionDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiMethods{
 static Future<String> seachCoordinateAddress(Position position, context) async{
   String placeAddress = "";
   String addressNo;
   String addressPla;
   String addressDetail;
  //  String addressDetail2;
   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
   var response = await Api.getUrl(url);
   if(response != "failed"){
    //  placeAddress = response["results"][0]["formatted_address"];
    addressNo = response["results"][0]["address_components"][0]["long_name"];
    addressPla = response["results"][0]["address_components"][1]["long_name"];
    addressDetail = response["results"][0]["address_components"][2]["short_name"];
    // addressDetail2 = response["results"][0]["address_components"][3]["long_name"];
     placeAddress =  addressNo + "," + addressPla + ", " + addressDetail;
     Address userPickUpAddress = new Address();
     userPickUpAddress.longitude = position.longitude;
     userPickUpAddress.latitude = position.latitude;
     userPickUpAddress.placeName = placeAddress;

     Provider.of<AppData>(context, listen: false).updatePickUplocation(userPickUpAddress);
   }
   return placeAddress;
 }




 static Future<DirectionDetails> obtainDirections(LatLng initialPosition, LatLng finalPosition) async{
   String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";
  
  var res = await Api.getUrl(directionUrl);
  if(res == "failed"){
    return null;
  }

  DirectionDetails directionDetails = DirectionDetails();
  directionDetails.encodedPoints =  res["routes"][0]["overview_polyline"]["points"];
  directionDetails.distanceText =  res["routes"][0]["legs"][0]["distance"]["text"];
  directionDetails.distanceValue =  res["routes"][0]["legs"][0]["distance"]["value"];

  directionDetails.durationText =  res["routes"][0]["legs"][0]["duration"]["text"];
  directionDetails.durationValue =  res["routes"][0]["legs"][0]["duration"]["value"];
  
  print(res["routes"]);
  return directionDetails;
 
 }


 static int calculateFares(DirectionDetails directionDetails)
 {
   //in term of USD
   double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
   double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
   double totalFareAmount = timeTraveledFare + distanceTraveledFare;

   //1$ = 450 Naira, convert to Naira
   double convertToNigeriatotalFarAmt  = totalFareAmount * 450;

   return convertToNigeriatotalFarAmt.truncate();
 }


 static void getCurrentOnlineUserInfo() async
 {
   firebaseUser = FirebaseAuth.instance.currentUser;
   String userId = firebaseUser.uid;
   DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users').child(userId);
   databaseReference.once().then((DataSnapshot datasSnapShot){
     if(datasSnapShot.value != null){
       currentUser = Users.fromSnapshot(datasSnapShot);
     }
   });
 }  
}