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
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AddAsset.dart';
import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'AssetsView.dart';
import 'BarChart.dart';
import 'Cases.dart';
import 'CasesScreen.dart';
import 'HeatMap.dart';
import 'LoginScreen.dart';
import 'NfcManager.dart';
import 'PermissionCheck.dart';
import 'RaiseAlert.dart';
import 'ScanPage.dart';
import 'SettingsRepository.dart';
import 'Site.dart';
import 'SiteDraw.dart';
import 'Theme/custom_theme.dart';
import 'Ticket.dart';

late var serverAddress;
//remote debugging
var protocol = 'https';
var socketProtocol = 'wss';
var port = ':443/landscaper-service';
var fabInRail =
    userDetails.featureToggles.contains("raiseAlert") ? true : false;
var fabMode = 'raiseAlert';
late var token;
//local environment
//var protocol = 'http';
//var socketProtocol = 'ws';
//var port = ':8080';

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
    url: socketProtocol + '://' + serverAddress + port + '/websocket',
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
      theme: CustomTheme.lightTheme,

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

      if (MediaQuery.of(context).size.width > 700 &&
          userDetails.featureToggles.contains("kanban")) ...[
        //HeatMap(client: stompClient),
        WorkflowKanban(client: stompClient),
      ],

      //(ticket: _createTicket),
      if (MediaQuery.of(context).size.width < 700 &&
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
      if (MediaQuery.of(context).size.width > 700 &&
          userDetails.featureToggles.contains("kanban")) ...[
        AdaptiveScaffoldDestination(
            title: 'Ops Board', icon: Icons.space_dashboard),
      ],
      if (MediaQuery.of(context).size.width < 700 &&
          userDetails.featureToggles.contains("cases")) ...[
        AdaptiveScaffoldDestination(
            title: 'Tickets', icon: Icons.confirmation_number),
      ],
      if (userDetails.featureToggles.contains("assets")) ...[
        AdaptiveScaffoldDestination(title: 'Assets', icon: Icons.coffee_maker),
      ],
    ];

    void _onItemTapped(int index) {
      setState(() {
        if (userDetails.featureToggles.contains("raiseAlert"))
          fabInRail = true;
        else
          fabInRail = false;

        fabMode = "raiseAlert";

        if (_children[index].runtimeType == AssetsView &&
            userDetails.featureToggles.contains("assets")) {
          fabInRail = true;
          fabMode = "addAsset";
        }
        if (_children[index].runtimeType == SplitView &&
            userDetails.featureToggles.contains("raiseAlert")) {
          fabInRail = true;
          fabMode = "raiseAlert";
        }
        if (_children[index].runtimeType == SiteDraw) {
          fabInRail = false;
        }

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
        return Color(0xFF25b432);
      }
      return Colors.black45;
    }

    int _destinationCount = _allDestinations.length;

    bool _includeBaseDestinationsInMenu = true;

    return AdaptiveNavigationScaffold(
      floatingActionButton: fabInRail ? getActionButtong(context) : null,
      navigationTypeResolver: (context) {
        if (MediaQuery.of(context).size.width > 700) {
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
            if (userDetails.featureToggles.contains("qr")) ...[
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Identify Asset',
                onPressed: () async {
                  var hasFound = false;
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Scaffold(
                            appBar: AppBar(
                              title: Text("Identify Asset"),
                            ),
                            body: AppBarcodeScannerWidget.defaultStyle(
                              resultCallback: (String code) {
                                if (!hasFound) {
                                  Navigator.pop(context);
                                  hasFound = true;
                                  AssetsView().showFindMyDialog(context, code);
                                }
                              },
                            )),
                        fullscreenDialog: false,
                      ));
                },
              )
            ]
          ],
          backgroundColor: Colors.white,
          toolbarHeight: 42,
          title: Text('MyBuildings.live',
              style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Color(0xFF136d1b),
                  fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
          leading: Column(children: <Widget>[
            Text(
                _packageInfo.version.toString() +
                    '+' +
                    _packageInfo.buildNumber.toString(),
                style: TextStyle(color: Colors.white))
          ])),
      body: _children[_currentIndex],
      fabInRail: true,
      includeBaseDestinationsInMenu: _includeBaseDestinationsInMenu,
    );
  }
}

FloatingActionButton getActionButtong(BuildContext context) {
  switch (fabMode) {
    case "addAsset":
      {
        return FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.domain_add),
            onPressed: () {
              if (PermissionCheck.check(PermissionCheck.ADD_ASSET, context)) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => AddAsset(
                        site: sites.sites[1].name, stompClient: stompClient),
                    //fullscreenDialog: true,
                  ),
                );
              }
            });
      }
      break;
    case "raiseAlert":
      {
        return FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              if(PermissionCheck.check(PermissionCheck.RAISE_ALERT, context)){
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      RaiseAlert(stompClient: stompClient),
                  //fullscreenDialog: true,
                ),
              );
            }
            });
      }
      break;
    default:
      {
        return FloatingActionButton(onPressed: () {
          // Add your onPressed code here!
        });
      }
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

  Map<String, dynamic> toJson() => {
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
    final screenWidth = MediaQuery.of(context).size.width;
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
//          Container(width: 0, color: Colors.transparent),
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
