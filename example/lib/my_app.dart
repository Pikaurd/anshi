import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_schema/graphql_schema.dart';
import 'package:anshi/anshi.dart';
import 'package:anshi/src/store/store.dart';
import 'package:anshi/src/store/bloc_provider.dart';
import 'package:anshi/src/store/graphql_bloc.dart';

// StatefulWidget MyApp() {
//   return (BlocProvider<GraphQLBloc>(
//     bloc: GraphQLBloc('query X { counter { count } }'),
//     child: My_App(),
//   ));
// }

class CounterModel {
  int count = 0;

  static GraphQLObjectType get type => objectType('counter', fields: [
    field('count', graphQLInt, resolve: (obj, _) => obj.count),
  ]);
}

var aGlobalCounter = CounterModel();
final store = NaiveStore(graphQLSchema(
  queryType: objectType('Query', fields: [
    field('counter', CounterModel.type, resolve: (_, __) => aGlobalCounter),
  ]),
  mutationType: objectType('Mutation', fields: [
    field('addCount', graphQLInt, resolve: (obj, args) {
      print('obj: $obj \t args: $args');
      aGlobalCounter.count += 1;
      return aGlobalCounter;
    }),
  ]),
));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anshi Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<GraphQLBloc>(
        bloc: GraphQLBloc('query X { counter { count } }'),
        child: CounterPage(title: 'Anshi Demo Counter'),
      ),
      // home: CounterPage(title: 'Anshi Demo Counter'),
      // home: MyHomePage(title: 'Anshi Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({Key key, this.title}) : super(key: key);

  final String title;

  void _incrementCounter() {
    print('commit mutation: counter + 1');
    store.client.parseAndExecute('mutation X { addCounter }');
  }
  
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<GraphQLBloc>(context);
    print('bloc.query: ${bloc.query}');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: StreamBuilder<dynamic>(
          stream: bloc.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '_counter: ${snapshot.data}',
                  style: Theme.of(context).textTheme.display1,
                ), 
              ]
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
