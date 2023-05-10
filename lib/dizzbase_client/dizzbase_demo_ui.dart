
// ignore_for_file: slash_for_doc_comments, prefer_const_constructors

import 'package:dizzbase_demo/dizzbase_client/dizzbase_transactions.dart';
import 'package:flutter/material.dart';
import 'dizzbase_connection.dart';
import 'dizzbase_query.dart';

class DemoTable extends StatefulWidget {
  const DemoTable(this.title, this.query, {super.key});
  final DizzbaseQuery query;
  final String title;

  @override
  State<DemoTable> createState() => _DemoTableState();
}

class _DemoTableState extends State<DemoTable> {
  late DizzbaseConnection dizzbaseClient;

  @override
  void initState() {
    dizzbaseClient = DizzbaseConnection();
    super.initState();
  }

    @override
  void dispose() {
    // IMPORTANT!
    dizzbaseClient.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text (widget.title, style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
        const SizedBox (height: 10,),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: dizzbaseClient.streamFromQuery(widget.query),
          builder: ((context, snapshot) {
            if (snapshot.hasData)
            {
              return DemoTableLayout(snapshot.data!);
            }
            return const CircularProgressIndicator();
          })),
        const SizedBox (height: 20,),
      ],
    );
  }
}

class DemoTableLayout extends StatelessWidget {
  const DemoTableLayout(this.data, {super.key});
  final List<Map<String, dynamic>> data;

  List<TableRow> getRows (List<Map<String, dynamic>> d)
  {
    List<TableRow> lr = [];
    List<TableCell> lc = [];
    d[0].forEach((key, value) {
      lc.add(TableCell (child: Text ("$key    ", style: const TextStyle(fontWeight: FontWeight.bold)),));
    });

    lr.add(TableRow(children: lc));
    for (var row in d) { 
      lc = [];
      row.forEach((key, value) {
        lc.add(TableCell (child: Text ("$value   "),));
      });
      lr.add(TableRow (children: lc));
    }
    return lr;
  }

  @override
  Widget build(BuildContext context) {
    return Table (
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: getRows (data),
    );
  }
}

/**************** UPDATE A TABLE  ****************/
class DemoUpdateEmployee extends StatefulWidget {
  const DemoUpdateEmployee({super.key});

  @override
  State<DemoUpdateEmployee> createState() => _DemoUpdateEmployeeState();
}
class _DemoUpdateEmployeeState extends State<DemoUpdateEmployee> {
  final TextEditingController _controllerName = TextEditingController(text: "NewName");
  final TextEditingController _controllerEmail = TextEditingController(text: "newEmail@mail.com");
  int rowsAffected = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Row (mainAxisAlignment: MainAxisAlignment.start, children: [
        const Text ("Update Name of Employee #2:     ", style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(width: 150, child: TextField(controller: _controllerName,)),
        SizedBox(width: 20,),
        SizedBox(width: 150, child: TextField(controller: _controllerEmail,)),
        SizedBox(width: 20,),
        ElevatedButton(child: Text("UPDATE"), onPressed: (){
            DizzbaseConnection().updateTransaction(
              DizzbaseUpdate(table: "employee", fields: ["employee_name", "employee_email"], 
                values: [_controllerName.text, _controllerEmail.text], filters: [Filter('employee', 'employee_id', 2)]))
              // ERROR HANDLING and show how many rows were updated:
              .then((result) {
                if (result["error"]!= "") { throw Exception(result["error"]); }
                setState(() => rowsAffected = result["rowCount"]);
              });
        }),
        (rowsAffected != -1)?Text("  Rows updated: $rowsAffected.", style: TextStyle (color: Colors.green),):Container()
      ],),
    );
  }
}


/**************** INSERT INTO A TABLE  ****************/
class DemoInsertOrder extends StatefulWidget {
  const DemoInsertOrder({super.key});

  @override
  State<DemoInsertOrder> createState() => _DemoInsertOrderState();
}
class _DemoInsertOrderState extends State<DemoInsertOrder> {
  final TextEditingController _controllerName = TextEditingController(text: "NewOrderName");
  final TextEditingController _controllerRevenue = TextEditingController(text: "200.00");
  int insertedRowPrimaryKey = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Row (mainAxisAlignment: MainAxisAlignment.start, children: [
        const Text ("Insert Order (name, revenue) for Employee #2 and Customer #1:   ", style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(width: 150, child: TextField(controller: _controllerName,)),
        SizedBox(width: 20,),
        SizedBox(width: 150, child: TextField(controller: _controllerRevenue,)),
        SizedBox(width: 20,),
        ElevatedButton(child: Text("INSERT"), onPressed: (){
            DizzbaseConnection().insertTransaction(
              DizzbaseInsert(table: "order", fields: ["order_name", "customer_id", "sales_rep_id", "services_rep_id", "order_revenue"], 
                values: [_controllerName.text, 1, 2, 2, _controllerRevenue.text]))
          // RETRIEVING THE PRIMARY KEY: This is executed after we get back the result of the transaction. 
          // Instead of "pkey" you can also access the key by using it's column name: data["order_id"] in this case.
          .then((data) => setState(() => insertedRowPrimaryKey = data));
        }),
        (insertedRowPrimaryKey==0)?Container():Text ("   The primary key of the new row is $insertedRowPrimaryKey.", style: TextStyle (color: Colors.green),),
      ],),
    );
  }
}


/**************** DELETE A ROW  ****************/
class DemoDeleteOrder extends StatefulWidget {
  const DemoDeleteOrder({super.key});

  @override
  State<DemoDeleteOrder> createState() => _DemoDeleteOrderState();
}
class _DemoDeleteOrderState extends State<DemoDeleteOrder> {
  final TextEditingController _controllerOrderId = TextEditingController(text: "1");
  int rowsAffected = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Row (mainAxisAlignment: MainAxisAlignment.start, children: [
        const Text ("Delete order:     ", style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(width: 150, child: TextField(controller: _controllerOrderId,)),
        SizedBox(width: 20,),
        ElevatedButton(child: Text("DELETE"), onPressed: (){
            DizzbaseConnection().deleteTransaction(
              DizzbaseDelete(table: 'order', filters: [Filter('order', 'order_id', _controllerOrderId.text)]))
              // ERROR HANDLING and show how many rows were deleted:
              .then((result) {
                if (result["error"]!= "") { throw Exception(result["error"]); }
                setState(() => rowsAffected = result["rowCount"]);
              });
        }),
        (rowsAffected != -1)?Text("  Rows deleted: $rowsAffected.", style: TextStyle (color: Colors.green),):Container()
      ],),
    );
  }
}

