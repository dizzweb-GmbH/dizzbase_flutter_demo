// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print
import 'package:dizzbase_demo/dizzbase_demo_login.dart';
import 'package:flutter/material.dart';
import 'package:dizzbase_client/dizzbase_client.dart';
import 'dizzbase_demo_ui.dart';


class DizzbaseDemoWidget extends StatefulWidget {
  const DizzbaseDemoWidget({super.key});

  @override
  State<DizzbaseDemoWidget> createState() => _DizzbaseDemoWidgetState();
}

class _DizzbaseDemoWidgetState extends State<DizzbaseDemoWidget> {
  late DizzbaseConnection dizzbaseConnectionForManualWidget;
  late DizzbaseConnection dizzbaseConnectionForDirectSQL;
  late Stream<DizzbaseResultRows> _streamForManualWidget;
  int employeeCount = -1;
  bool backendConnected = false;

  void dizzbaseConnectionStatusCallback (bool connected)
  {
    setState(() => backendConnected = connected);
  }

  @override
  void initState() {
    // This could be done with one Connection only, we are using two for testing:
    dizzbaseConnectionForManualWidget = DizzbaseConnection(connectionStatusCallback: dizzbaseConnectionStatusCallback, nickName: "ManualWidget");
    _streamForManualWidget = dizzbaseConnectionForManualWidget.streamFromQuery(DizzbaseQuery(table: MainTable("employee", pkey: 3), nickName: "StreamedDirectUse"));
    dizzbaseConnectionForDirectSQL = DizzbaseConnection(nickName: "DirectSQL");
    super.initState();
  }

  @override
  void dispose() {
    // IMPORTANT!
    dizzbaseConnectionForManualWidget.dispose();
    dizzbaseConnectionForDirectSQL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // This dizzbase connection state indicator is triggered through the connectionStatusCallback function parameter of the dizzbaseConnection object 
            // see function dizzbaseConnectionStatusCallback and the code in initState above:
            Row (children: [(backendConnected)?Text("Backend CONNECTED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),):
                Text("Backend DISCONNECTED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),), Text ("   (Turn the backend off and on again to see how the status changes)"),
                SizedBox (width: 20), ElevatedButton(onPressed: (){DizzbaseLogin.showLoginDialog(context);}, child: Text ("Login"))
              ]),
            
            SizedBox (height: 10,),                      
            DemoTable("Single Record with Primary Key - shortcut", DizzbaseQuery.singleRow ('employee', 2, nickName: "SingleRowEmployee"), widgetConnectionNickName: "SingleRowEmployee",),
            
            // Demo of how a list of orders is automatically updated when a new order is added.
            DemoTable("Orders list for Employee #2 as sales rep (will be updated if you insert a new order for this employee)", DizzbaseQuery(
              table: MainTable("order"), 
              joinedTables: [JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey:  'sales_rep_id' )],
              filters: [Filter('employee', 'employee_id', 2)], nickName: "ComplexQuery"), widgetConnectionNickName: "ComplexQuery",),
            
            // Search with a LIKE statement.
            DemoTable("Single Table with pattern search LIKE '%hotmail%'", DizzbaseQuery(table: MainTable("employee"), filters: [Filter('employee', 'employee_email', '%hotmail%', comparison: 'LIKE')], nickName: "LIKESearch"), widgetConnectionNickName: "LIKESearch",),

            // Complex query      
            DemoTable("Complex multi-table query with WHERE and ORDER BY", DizzbaseQuery(
              table:
                MainTable('order'),
              joinedTables:
              [
                // Automatic JOIN: This will include all columns, and the JOIN to the MainTable will be added automatically using the constraint information in the database
                JoinedTable('customer'), 
                // Join the same table two time, so we need to add aliases. 
                // Observe that the columns for tables with aliases are named differently in the output table - "seller_employee_name" instead of just "employee_name"
                JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey: 'sales_rep_id', columns: ['employee_name', 'employee_email'], alias: 'seller'),
                JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey: 'services_rep_id', columns: ['employee_name'], alias: 'consultant'),
              ],
              sortFields: 
              [
                // Note the the alias is used for sorting, rather than the table name (as the table is part of two joins)
                SortField('seller', 'employee_name', ascending: false), 
                SortField('order', 'order_id', ascending: false), 
              ],
              filters: 
              [
                Filter ('order', 'order_revenue', 50, comparison: ">="),
              ], nickName: "MultiTableComplex",
            ), widgetConnectionNickName: "MultiTableComplex",),
      
            // Here wir are directly using the data for the stream without the DemoTable logic, to demonstrate how you can build widgets:
            // Note the the dizzbaseConnection is initialized in the widget's initState. There has to be a separate dizzbaseClient for every widget/stream.
            // Also note that the dizzbaseConnection is disposed of in the dispose() function of the stateful widget.
            Text ("Directly using the data from the stream to compose widgets", style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
            const SizedBox (height: 10,),
            StreamBuilder<DizzbaseResultRows>(
            stream: _streamForManualWidget,
            builder: ((context, snapshot) {
              if (snapshot.hasData)
              {
                return Text ("Employee \"${snapshot.data!.data![0]['employee_name']}\" uses the email address \"${snapshot.data!.data![0]['employee_email']}\".");
              }
              if (snapshot.hasError) {throw Exception("Snapshot has error: ${snapshot.error}");}
              return Text ("Waiting for information on employee number 3...");
            })),
            const SizedBox (height: 5,),
    
            // Other important things to take care of:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text("Important: ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),), 
              Text ("Please note the initState() and dispose() overrides in stateful widgets when using DizzbaseConnection. Remember to call DizzbaseConnection.dispose() to free up server ressources!")],
            ),
            // Used for debugging the 'close' message to the server:
            // MaterialButton(child: const Text ("DISPOSE"), onPressed: ()=>dizzbaseConnectionForManualWidget.dispose()),
            SizedBox (height: 15,),
            DemoUpdateEmployee(),
            DemoInsertOrder(),
            DemoDeleteOrder(),
    
    
            const SizedBox (height: 10,),
            Row(
              children: [
                Text ("Send a SQL statement directly to the server without a stream. This does not real-time update.   ", style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold),),
                ElevatedButton(onPressed: () {
                  dizzbaseConnectionForDirectSQL.directSQLTransaction("SELECT count(*) AS c from employee").then ((result){
                    if (result.error!="") {throw Exception(result.error);}
                    // We get only one row (result[0]) and the column has been named "c":
                    setState(() => employeeCount = int.parse(result.data![0]["c"]));
                  });
                }, child: Text ("Send SQL: SELECT count(*) from employee")), SizedBox(width: 10,),
                (employeeCount==-1)?Container():Text ("Result of 'SELECT count(*) from employees: "), 
                (employeeCount==-1)?Container():Text (employeeCount.toString(), style: TextStyle (color: Colors.green),),
              ],
            ),
            const SizedBox (height: 5,),
            
          ],
        ),
      ),
    );
  }
}