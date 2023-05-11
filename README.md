# dizzbase Flutter client

Demo app that shows the usage of the dizzbase_client interface for the dizzbase node.js server.

dizzbase is a realtime postgreSQL backend-as-a-service for node.js express servers.
Clients (flutter/dart or JavaScript/React) can send query that are automatically updated in realtime.

dizzbase can be an alternative to self-hosting supabase if a lightweight and easy to install solution is needed.
Also, it can be used instead of firebase if you need a relational rather than document database. 

See https://www.npmjs.com/package/dizzbase for instruction on how to install/run the node.js backend with PostgreSQL.
See https://pub.dev/packages/dizzbase_client for more information on the flutter/dart dizzbase client.

## Getting Started

Install the dizzbase backend server (https://www.npmjs.com/package/dizzbase) and cofigure it for usage with your PostgreSql database as described in the backend server REAMDME.md

In the flutter apps main() function, call DizzbaseConnection.configureConnection(...) to configure your backend services URL and access token.

To understand how the dart/flutter dizzbase client works, look at dizzbase_demo_widget.dart first - there you can see how data is retrieved from the database.

In dizzbase_demo_ui.dart there are more widgets that demonstrate how to insert/update/delete data. There is also an example on how to directly send SQL to the backend an retrieve the result (without using a stream).

Note the initState() and dispose() overrides of the StatefulWidgets to see how to create and clean up the dizzbase connection and therefore to avoid backend memory leaks with long-running clients.
