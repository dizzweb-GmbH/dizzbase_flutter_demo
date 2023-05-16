# dizzbase Flutter client

IMPORTANT: This demo has only been tested as a flutter web/browser app!

The demo app that shows the usage of the dizzbase_client interface for the dizzbase node.js server.

dizzbase is a realtime postgreSQL backend-as-a-service for node.js express servers.
Clients (flutter/dart or JavaScript/React) can send query that are automatically updated in realtime.

dizzbase can be an alternative to self-hosting supabase if a lightweight and easy to install solution is needed.
Also, it can be used instead of firebase if you need a relational rather than document database. 

See https://www.npmjs.com/package/dizzbase for instruction on how to install/run the node.js backend with PostgreSQL.

See https://pub.dev/packages/dizzbase_client for more information on the flutter/dart dizzbase client.

## Getting Started

Install the dizzbase backend server (https://www.npmjs.com/package/dizzbase) and configure it for usage with your PostgreSql database as described in the backend server REAMDME.md

Install the demo data into the demo database before (!!!) you start the backend for the first time by running the shell script sql/testResetDB.sh included in the dizzbase npm module. You can also get the script from github https://github.com/dizzweb-GmbH/dizzbase. The shell script uses some of the *.sql files in the sql folder, so start it ```/bin/sh testResetDB.sql``` in the sql directory.

Check the pubspec.yaml file and edit (if necessary) how you load the dizzbase_client package. You can either load it via pub.dev or via a local path (in case you downloaded the dizzbase_client from https://github.com/dizzweb-GmbH/dizzbase_client_flutter).

In the demo app's apps main() function, edit ```DizzbaseConnection.configureConnection("http://localhost:3000", "my-security-token");``` to point to your backend services URL and access token.

Read the examples on how to use the API before looking at the demo client: https://github.com/dizzweb-GmbH/dizzbase_client_flutter/blob/main/example/example.md

To understand how the dart/flutter dizzbase client works, look at dizzbase_demo_widget.dart first - there you can see how data is retrieved from the database and displayed using the real-time mode.

In dizzbase_demo_ui.dart there are more widgets that demonstrate how to insert/update/delete data. There is also an example on how to directly send SQL to the backend an retrieve the result (without using a stream).

Note the initState() and dispose() overrides of the StatefulWidgets to see how to create and clean up the dizzbase connection and therefore to avoid backend memory leaks with long-running clients.
