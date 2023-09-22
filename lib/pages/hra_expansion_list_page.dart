import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/expansion_model.dart';
import 'package:leso_board_games/pages/hra_detail_page.dart';
import 'package:leso_board_games/services/get_hra_detail.dart';

class HraExpansionListPage extends StatefulWidget {
  final int objectId;
  final num gameValue;
  final String name;
  final List<ExpansionModel> expansions;

  const HraExpansionListPage({Key? key, required this.objectId, required this.expansions, required this.gameValue, required this.name})
      : super(key: key);

  @override
  _HraExpansionListPageState createState() => _HraExpansionListPageState();
}

class _HraExpansionListPageState extends State<HraExpansionListPage> {
  late Future<List<ExpansionModel>> _expansionData;
  num _totalGameValue = 0;

  @override
  void initState() {
    super.initState();
    _refreshPage();
  }

  Future<void> _calculateTotalGameValue(int parentGameId) async {
    final totalGameValue = await HrasDatabase.instance.getTotalGameValueByParentGameId(parentGameId);
    setState(() {
      _totalGameValue = totalGameValue; // Update the state variable
    });
  }

  void _navigateToDetailPage(int objectId) {
    _navigateToHraDetail(context, objectId);
  }

  Future<void> _navigateToHraDetail(BuildContext context, int objectId) async {
    final retrievedHra = await HrasDatabase.instance.getItemByObjectId(objectId);

    if (retrievedHra != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HraDetail(
            hraData: retrievedHra.toJson(),
            bgUserName: '', // Pass the bgUserName
            objectId: objectId,
          ),
        ),
      );

      if (result == true) {
        await _refreshPage();
      }
    }
  }

  Future<void> _refreshPage() async {
    // Fetch and update the data here
    _expansionData = getExpansionData(widget.objectId.toString());
    _calculateTotalGameValue(widget.objectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expansion List'),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              /// 1. ROW ==> Core Game info
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.greenAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.casino_rounded,
                                  size: 18,
                                  color: darkGrey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Core Boardgame name :',
                                  style: TextStyle(
                                    color: darkGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    maxLines: 2,
                                    widget.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 90,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Text(
                              '${widget.gameValue.toString()} €',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 2. ROW ==> static title expansions
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    color: Colors.yellow[100],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.extension,
                            size: 18,
                            color: darkGrey,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Expansions List :',
                            style: TextStyle(
                              color: darkGrey,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 2,5. ROW ==> Scroll List of expansions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Container(
                      color: Colors.yellow[100],
                      child: FutureBuilder<List<ExpansionModel>>(
                        future: _expansionData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No expansion data available'));
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final expansion = snapshot.data![index];
                                  return Column(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: basicLightGrey),
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            _navigateToDetailPage(int.parse(expansion.objectId!));
                                          },
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                expansion.thumbnail ?? '',
                                              ),
                                            ),
                                            title: Text(
                                              expansion.name ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            subtitle: Text('Object ID: ${expansion.objectId}'),
                                            trailing: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                width: 90,
                                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                child: Text(
                                                  '${expansion.gameValue} €',
                                                  style: const TextStyle(
                                                    color: Colors.yellow,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              /// 3. ROW ==> Sum value Info
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
                child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.topRight,
                                ),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.casino,
                                      size: 30,
                                      color: Colors.purpleAccent,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Total money spend for this game :',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  // width: 90,
                                  padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                                  child: Text(
                                    '${_totalGameValue.toStringAsFixed(2).toString()} €',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// Back BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[900],
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
