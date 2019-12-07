import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disciplinas',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  _MyHomePageState createState() {
      return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de disciplinas'),),
      body: _buildBody(context),
          );
        }
      
  Widget _buildBody(BuildContext context){
    // return _buildList(context, dummySnapshot);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data){
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.nome),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        
        child: ListTile(
          title: Text(record.nome),
          trailing: Text('Votos: ' + record.votes.toString()),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Id: ' + record.id.toString(), textAlign: TextAlign.left,),
              Text('Carga horária: ' + record.cargaHoraria.toString(), textAlign: TextAlign.left,),
            ],
          ),
          onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }
}

class Record{
  final int id;
  final String nome;
  final int cargaHoraria;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
    : assert(map['id'] != null),
      assert(map['nome'] != null),
      assert(map['cargaHoraria'] != null),
      assert(map['votes'] != null),
      id = map['id'],
      nome = map['nome'],
      cargaHoraria = map['cargaHoraria'],
      votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$id$nome:$cargaHoraria>";
}