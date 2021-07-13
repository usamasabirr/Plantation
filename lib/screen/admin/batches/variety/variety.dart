import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertest/screen/admin/batches/adminBatches.dart';
import 'package:fluttertest/screen/admin/batches/variety/addVariety.dart';
import 'package:fluttertest/screen/admin/batches/variety/varityInfoHome.dart';
import 'package:fluttertest/shared/loading.dart';
import 'package:http/http.dart' as http;
import '../../../../models/variety.dart';

List<VarietyModel> parseVarieties(String responseBody) {
  print('start parseBatch');
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  print('end patseBatch get');
  return parsed
      .map<VarietyModel>((json) => VarietyModel.fromJson(json))
      .toList();
}

class Variety extends StatefulWidget {
  Function navigateToAdminBatches;
  Function navigateToListVarieties;
  String batchId;
  Variety(
      this.batchId, this.navigateToAdminBatches, this.navigateToListVarieties);

  @override
  _VarietyState createState() => _VarietyState();
}

class _VarietyState extends State<Variety> {
  final spinkit = SpinKitChasingDots(
    color: Colors.grey[200],
    size: 50.0,
  );
  Future<List<VarietyModel>> getVarities(http.Client client) async {
    print('start filterVariety get');
    var queryParameters = {'batchId': widget.batchId};
    var uri = Uri.https(
        'hughplantation.herokuapp.com', '/filterVariety', queryParameters);
    print('Filter Variety uri is: $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {}

    print(response);
    print('end filterVariety get');
    return compute(parseVarieties, response.body);
  }

  Future<String> getShiftBatches(http.Client client) async {
    print('start getShiftBatches get');
    var queryParameters = {'BatchId': widget.batchId};
    var uri = Uri.https(
        'hughplantation.herokuapp.com', '/shiftBatches', queryParameters);
    print('Filter Variety uri is: $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      print('successfully shifted batch');
      return 'success';
    } else {
      print('error shifting batch');
      return 'error';
    }
  }

  void navigateToVarietyInfoHome(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VarietyInfoHome(id, navigateToVarietyInfoHome)));
  }

  void showDialogBox(bool flag) {
    showCupertinoDialog(
        context: context,
        builder: (_) => Container(
              child: AlertDialog(
                content: Container(width: 50, height: 50, child: spinkit),

                // actions: [
                //   FlatButton(
                //     onPressed: () {za
                //       Navigator.pop(context);
                //     },
                //     child: Text('No'),
                //   ),
                //   FlatButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     child: Text('Ok'),
                //   ),
                // ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    print('hello');
    return Scaffold(
      appBar: AppBar(
        title: Text('Variety List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddVariety(
                        widget.batchId, widget.navigateToListVarieties)));
          },
          label: Text('Add Variety')),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 300,
              child: FutureBuilder(
                future: getVarities(http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(snapshot.data[index].varietyName),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VarietyInfoHome(
                                          snapshot.data[index].varietyId,
                                          navigateToVarietyInfoHome)));
                            },
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text('Error');
                  } else {
                    return Loading();
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 40.0,
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Colors.greenAccent,
                color: Colors.blue,
                elevation: 7.0,
                child: GestureDetector(
                  onTap: () async {
                    showDialogBox(true);
                    await getShiftBatches(http.Client());
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);

                    widget.navigateToAdminBatches();
                  },
                  child: Center(
                    child: Text(
                      'Add to Processing',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
