import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';

class GraphConfiguration {
  final String title;
  final String description;
  final GameSubtype subtype;
  final Future<List<YearlyGameData>> Function(GameSubtype) dataGetter; // Updated data type
  final List<Color> barColors;
  final Color textColor;

  GraphConfiguration({
    required this.title,
    required this.description,
    required this.barColors,
    required this.textColor,
    required this.subtype,
    required this.dataGetter, // Updated parameter
  });

  Future<List<YearlyGameData>> fetchData(GameSubtype subtype) async {
    return dataGetter(subtype);
  }
}

class StatisticGraphPage extends StatelessWidget {
  final hrasDatabase = HrasDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Grey background
      appBar: AppBar(
        backgroundColor: Colors.black, // Darker grey for app bar
        title: const Text("Statistic Graphs"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var config in graphConfigurations) _buildGraphContainer(config),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back when button is pressed
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildGraphContainer(GraphConfiguration config) {
    return FutureBuilder<List<YearlyGameData>>(
      // Fetch graph data asynchronously
      future: config.dataGetter(config.subtype), // Pass the GameSubtype to the dataGetter

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'No data available :  ${config.title}',
            style: const TextStyle(color: darkGrey),
          );
        }

        final sortedData = snapshot.data!..sort((a, b) => a.year.compareTo(b.year));

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tileDarkGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Row(
                  children: [
                    const Icon(
                      Icons.query_stats_rounded,
                      color: (middleGrey),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      config.title, // Use the title from the configuration
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: basicLightGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              /// Graph Container
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Container(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: getBarTouchTooltipData(config, sortedData),
                      ),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (context, value) => const TextStyle(color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 12),
                          margin: 20,
                          getTitles: (value) {
                            return value.toInt().toString();
                          },
                        ),
                        topTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                        leftTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                        ),
                      ),
                      barGroups: [
                        for (var entry in sortedData)
                          _buildBarWithLabel(entry.year, entry.sumValue.toDouble(), entry.barCounterValue, config.barColors),
                      ],
                      groupsSpace: 50,
                    ),
                  ),
                ),
              ),
              // Add a box with rounded corners
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 50, // Description area height
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: middleGrey,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Text(
                              config.description, // Use the description from the configuration
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: middleGrey),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

BarTouchTooltipData getBarTouchTooltipData(GraphConfiguration config, List<YearlyGameData> data) {
  return BarTouchTooltipData(
    tooltipBgColor: Colors.transparent,
    tooltipMargin: -5,
    getTooltipItem: (
      BarChartGroupData group,
      int groupIndex,
      BarChartRodData rod,
      int rodIndex,
    ) {
      final yearlyData = data[groupIndex];

      return BarTooltipItem(
        ' (${yearlyData.barCounterValue})\n${rod.y.toStringAsFixed(0)} €',
        TextStyle(
          color: config.textColor,
          fontWeight: FontWeight.normal,
        ),
      );
    },
  );
}

BarChartGroupData _buildBarWithLabel(int xValue, double yValue, int barCounterValue, List<Color> barColors) {
  return BarChartGroupData(
    x: xValue,
    barsSpace: 5,
    barRods: [
      BarChartRodData(
        y: yValue,
        width: 30,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        colors: barColors,
      ),
    ],
    showingTooltipIndicators: [0],
  );
}

final List<GraphConfiguration> graphConfigurations = [
  GraphConfiguration(
    title: "Sum of All stuff per Years",
    description: "This graph displays SUM of money you spent for the Games and Expansions, during each year and compares them.",
    barColors: [Colors.deepPurple, Colors.blue, Colors.cyan], // Specify the bar colors
    textColor: Colors.cyan,
    subtype: GameSubtype.all,
    dataGetter: HrasDatabase.instance.getSumOfGameValueForEachYear,
  ),
  GraphConfiguration(
    title: "Sum of Games Value per Years",
    description: "This graph displays SUM of money you spent for the Games, during each year and compares them.",
    barColors: [Colors.green, Colors.greenAccent, Colors.limeAccent],
    textColor: Colors.tealAccent, // Specify the bar colors
    subtype: GameSubtype.boardgame,
    dataGetter: HrasDatabase.instance.getSumOfGameValueForEachYear,
  ),
  GraphConfiguration(
    title: "Sum of Expansions Value per Years",
    description: "This graph displays SUM of money you spent for theExpansions, during each year and compares them.",
    barColors: [Colors.orange, Colors.yellow, Colors.yellowAccent],
    textColor: Colors.yellowAccent, // Specify the bar colors
    subtype: GameSubtype.boardgameexpansion,
    dataGetter: HrasDatabase.instance.getSumOfGameValueForEachYear,
  ),
  GraphConfiguration(
    title: "Sum of Accessories Value per Years",
    description:
        "This graph displays SUM of money you spent for the Accessories for the games such as card sleeves tokens and etc. during each year and compares them.",
    barColors: [Colors.indigo, Colors.blue, Colors.blueAccent],
    textColor: Colors.blueAccent, // Specify the bar colors
    subtype: GameSubtype.accessories,
    dataGetter: HrasDatabase.instance.getSumOfGameValueForEachYear,
  ),
];

void main() {
  runApp(MaterialApp(
    home: StatisticGraphPage(),
  ));
}
