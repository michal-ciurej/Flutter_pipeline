import 'dart:convert';
import 'dart:io';

import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:alerts/AlertsScreen.dart';
import 'package:alerts/LineChart.dart';
import 'package:alerts/TicketCalender.dart';
import 'package:alerts/WorkflowKanban.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'AssetsView.dart';
import 'BarChart.dart';
import 'Cases.dart';
import 'CasesScreen.dart';
import 'HeatMap.dart';
import 'LoginScreen.dart';
import 'NfcManager.dart';
import 'ScanPage.dart';
import 'Settings.dart';
import 'Site.dart';
import 'SiteDraw.dart';
import 'Ticket.dart';

late var serverAddress;
var protocol = 'http';
var socketProtocol = 'ws';

void onConnect(StompFrame frame) {
  stompClient.subscribe(
    destination: '/topic/messages',
    callback: (frame) {
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      messages.add(result);
    },
  );
  //specific queu for messages back to this client
  stompClient.subscribe(
    destination: '/user/topic/sites',
    callback: (frame) {
      print("Recieved all the sites");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      sites.add(result);
      print("Finished adding  all the sites");
    },
  );

  stompClient.subscribe(
    destination: '/user/topic/assets',
    callback: (frame) {
      print("Recieved all the assets");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      assets.add(result);
    },
  );

  stompClient.subscribe(
    destination: '/topic/assets',
    callback: (frame) {
      print("Recieved all the assets");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      assets.add(result);
    },
  );

  stompClient.subscribe(
    destination: '/user/topic/reply',
    callback: (frame) {
      print("Recieved all the alarms");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      messages.add(result);
    },
  );

  stompClient.subscribe(
    destination: '/user/topic/cases',
    callback: (frame) {
      print("Receiving and adding cases");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      cases.add(result);
    },
  );

  stompClient.subscribe(
    destination: '/topic/cases',
    callback: (frame) {
      print("Receiving and adding cases");
      List<Map<String, dynamic>> result =
      List<Map<String, dynamic>>.from(json.decode(frame.body!));
      cases.add(result);
    },
  );

  stompClient.send(
    destination: '/app/sites',
  );

  stompClient.send(
    destination: '/app/alerts',
  );

  stompClient.send(
    destination: '/app/assets',
  );

  stompClient.send(destination: '/app/cases', body: '573');

  stompClient.subscribe(
    destination: '/topic/status',
    callback: (frame) {
      Map<String, dynamic> result =
      Map<String, dynamic>.from(json.decode(frame.body!));
      messages.update(result);
    },
  );
}

final stompClient = StompClient(
  config: StompConfig(
    url: socketProtocol + '://' + serverAddress + ':8080/landscaper-service/websocket',
    onConnect: onConnect,
    beforeConnect: () async {
      await dotenv.load(fileName: '.env');

      serverAddress = dotenv.env['SERVER_IP'].toString();
      ;

      print('waiting to connect to ' + serverAddress);

      print('connecting...');
    },
    onWebSocketError: (dynamic error) => print(error.toString()),
    onWebSocketDone: () => print("finished setting up socket ok"),
    stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
    webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
  ),
);

AppMessages messages = AppMessages();
Sites sites = new Sites();
Cases cases = new Cases();
Assets assets = new Assets();
UserDetails userDetails = UserDetails("");

int _currentIndex = 0;

void main() async {
  await dotenv.load(fileName: '.env');

  serverAddress = dotenv.env['SERVER_IP'].toString();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
      SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  HttpOverrides.global = MyHttpOverrides();

  stompClient.activate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => sites),
        ChangeNotifierProvider(create: (context) => messages),
        ChangeNotifierProvider(create: (context) => cases),
        ChangeNotifierProvider(create: (context) => assets)
      ],
      child: const MyApp(),
    ),
  );

  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en', ''),
      ],
      localizationsDelegates: [
        FormBuilderLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'Landscaper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Alerts'),
      //navigatorObservers: [TransitionRouteObserver()],
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(client: stompClient),
        '/': (context) => MyHomePage(),
      },
    );

    ;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
  }

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

// Pass this method to the child page.
  void _update(String id) {
    print('sending update for ' + id);
    stompClient.send(
      destination: '/app/ack',
      body: json.encode({'id': id}),
    );
  }

  void _raiseTicket(int count) {
    setState(() => _currentIndex = count);
  }

  void _createTicket(TicketModel ticket) {
    print("sending ticket request to server");
    //ticket.alertId = "573";
    stompClient.send(
      destination: '/app/newTicket',
      body: jsonEncode(ticket.toJson()),
    );
    setState(() => _currentIndex = 0);
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List _children = [
      //  AlertsScreen(update: _update, ticket: _raiseTicket, client: stompClient,),
      SplitView(update: _update, ticket: _raiseTicket, client: stompClient),
      SiteDraw(),
      if (userDetails.featureToggles.contains("calender")) ...[
        TicketCalender(client: stompClient),
      ],
      if (userDetails.featureToggles.contains("nfc")) ...[
        NfcManager(client: stompClient),
      ],

      if (MediaQuery
          .of(context)
          .size
          .width > 700 &&
          userDetails.featureToggles.contains("kanban")) ...[
        //HeatMap(client: stompClient),
        WorkflowKanban(client: stompClient),
      ],

      //(ticket: _createTicket),
      if (MediaQuery
          .of(context)
          .size
          .width < 700 &&
          userDetails.featureToggles.contains("cases")) ...[
        CasesScreen(update: _update, ticket: _raiseTicket, client: stompClient),
      ],
      if (userDetails.featureToggles.contains("assets")) ...[AssetsView()],
    ];

    var _allDestinations = [
      AdaptiveScaffoldDestination(title: 'Alerts', icon: Icons.home),
      AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.tune),
      if (userDetails.featureToggles.contains("calender")) ...[
        AdaptiveScaffoldDestination(title: 'Calender', icon: Icons.event),
      ],
      if (userDetails.featureToggles.contains("nfc")) ...[
        AdaptiveScaffoldDestination(title: 'NFC', icon: Icons.nfc),
      ],
      if (MediaQuery
          .of(context)
          .size
          .width > 700 &&
          userDetails.featureToggles.contains("kanban")) ...[
        AdaptiveScaffoldDestination(
            title: 'Ops Board', icon: Icons.space_dashboard),
      ],
      if (MediaQuery
          .of(context)
          .size
          .width < 700 &&
          userDetails.featureToggles.contains("cases")) ...[
        AdaptiveScaffoldDestination(
            title: 'Tickets', icon: Icons.confirmation_number),
      ],
      if (userDetails.featureToggles.contains("assets")) ...[
        AdaptiveScaffoldDestination(title: 'Assets', icon: Icons.coffee_maker),
      ],
    ];

    void _onItemTapped(int index) {
      print(index);
      setState(() {
        _currentIndex = index;
      });
    }

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.black45;
    }

    int _destinationCount = _allDestinations.length;
    bool _fabInRail = false;
    bool _includeBaseDestinationsInMenu = true;

    return AdaptiveNavigationScaffold(
      navigationTypeResolver: (context) {
        if (MediaQuery
            .of(context)
            .size
            .width > 700) {
          return NavigationType.rail;
        } else {
          return NavigationType.bottom;
        }
      },
      onDestinationSelected: _onItemTapped,
      selectedIndex: _currentIndex,
      drawerHeader: Text("Drawer"),
      destinations: _allDestinations.sublist(0, _destinationCount),
      appBar: AdaptiveAppBar(
          actions: <Widget>[
            if(1 == 1)...[

              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Identify Asset',
                onPressed: () async {
                  var hasFound=false;
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext
                        context) =>
                            Scaffold(
                                appBar: AppBar(
                                  title: Text(
                                      "Identify Asset"),
                                ),
                                body:
                                AppBarcodeScannerWidget
                                    .defaultStyle(
                                  resultCallback:
                                      (String code) {

                                    if(!hasFound) {
                                      Navigator.pop(context);
                                      hasFound=true;
                                      AssetsView().showFindMyDialog(
                                          context,
                                          code);


                                    }
                                  },
                                )),
                        fullscreenDialog: false,
                      ));
                },
              )
            ]
          ],
          toolbarHeight: 100,
          title: Text('Landscaper'),
          leading: Column(children: <Widget>[
            Container(
                height: 65,
                child: Image.network(protocol +
                    '://' +
                    serverAddress +
                    ':8080/landscaper-service/api/static/fr.png')),
            Text(
                _packageInfo.version.toString() +
                    '+' +
                    _packageInfo.buildNumber.toString(),
                style: TextStyle(color: Colors.white))
          ])),
      body: _children[_currentIndex],
      fabInRail: _fabInRail,
      includeBaseDestinationsInMenu: _includeBaseDestinationsInMenu,
    ); /*Scaffold(
                  drawer: siteDraw(),
                  bottomNavigationBar: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Alerts',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.travel_explore),
                        label: 'Heat Map',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.work),
                        label: 'My Cases',
                      ),
                    ],
                    currentIndex: _currentIndex,
                    selectedItemColor: Colors.amber[800],
                    onTap: _onItemTapped,
                  ),
                  appBar: AppBar(
                    // Here we take the value from the MyHomePage object that was created by
                    // the App.build method, and use it to set our appbar title.
                    title: Text(widget.title),
                  ),
                  body: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return _children[_currentIndex];
                        } else {
                          return _children[0];
                        }
                      })
              );*/
  }
}


class TicketModel {
  var id;
  var description;
  var date;
  var site;
  var type;
  var alertId;
  var status;
  var assignee = 'None';

  Map<String, dynamic> toJson() =>
      {
        'date': date,
        'description': description,
        'site': site,
        'type': type,
        'alertId': alertId,
        'status': status,
        'id': id,
        'assignee': assignee
      };
}

class SplitView extends StatelessWidget {
  StompClient client;

  final ValueChanged<String> update;
  final ValueChanged<int> ticket;

  SplitView({required this.update, required this.ticket, required this.client});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    const breakpoint = 700.0;
    if (screenWidth >= breakpoint) {
      // widescreen: menu on the left, content on the right
      return Row(
        children: [
          // use SizedBox to constrain the AppMenu to a fixed width
          SizedBox(
            width: screenWidth / 5,
            // TODO: make this configurable
            child: SiteDraw(),
          ),
          // vertical black line as separator
          Container(width: 0.5, color: Colors.black),
          // use Expanded to take up the remaining horizontal space
          Expanded(
            // TODO: make this configurable
            child: AlertsScreen(
                update: update, ticket: ticket, client: stompClient),
          ),
          if (userDetails.featureToggles.contains("cases")) ...[
            SizedBox(
              width: screenWidth / 3,
              // TODO: make this configurable
              child: CasesScreen(
                  update: update, ticket: ticket, client: stompClient),
            )
          ]
        ],
      );
    } else {
      // narrow screen: show content, menu inside drawer
      return Scaffold(
        body: AlertsScreen(update: update, ticket: ticket, client: stompClient),
        // use SizedBox to contrain the AppMenu to a fixed width
        /*floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            child: const Icon(Icons.store),
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // <-- Opens drawer.
          );
        }),*/
        drawer: SizedBox(
          width: 240,
          child: Drawer(
            child: SiteDraw(),
          ),
        ),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
      true; // add your localhost detection logic here if you want
  }
}
