import 'package:flutter/material.dart';
import 'package:graphql_schema/graphql_schema.dart';
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
final schema = graphQLSchema(
  queryType: objectType('Query', fields: [
    field('counter', CounterModel.type, resolve: (_, __) => aGlobalCounter),
  ]),
  mutationType: objectType('Mutation', fields: [
    field('addCount', CounterModel.type, resolve: (obj, args) {
      print('obj: $obj \t args: $args');
      aGlobalCounter.count += 1;
      return aGlobalCounter;
    }),
  ]),
);
final store = NaiveStore(schema);

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
        bloc: GraphQLBloc('query X { counter { count } }', store, 'Counter'),
        child: CounterPage(title: 'Anshi Demo Counter'),
      ),
      // home: CounterPage(title: 'Anshi Demo Counter'),
      // home: MyHomePage(title: 'Anshi Demo Home Page'),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({Key key, this.title}) : super(key: key);

  final String title;
  GraphQLBloc bloc;

  void _incrementCounter() {
    print('commit mutation: counter + 1');
    store.commitMutation('mutation X { addCount }');
  }
  
  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<GraphQLBloc>(context);
    print('bloc.query: ${bloc.query}');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: StreamBuilder<dynamic>(
          stream: bloc.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print('snapshot: ${snapshot}');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '_counter: ${snapshot.data["counter"]["count"]}',
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
