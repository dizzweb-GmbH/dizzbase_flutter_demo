# dizzbase_demo

A new Flutter project.

## Getting Started

In the flutter apps main() function, call DizzbaseConnection.configureConnection(...) to configure your backend services URL and access token.

To understand how the dart/flutter dizzbase client works, look at dizzbase_demo_widget.dart first - there you can see how data is retrieved from the database.

In dizzbase_demo_ui.dart there are more widgets that demonstrate how to insert/update/delete data. There is also an example on how to directly send SQL to the backend an retrieve the result (without using a stream).

Note the initState() and dispose() overrides in the DemoTable widget to see how to properly clean up and avoid backend memory leaks with long-running clients.

## TODO 

Backend security (access token) is not yet implemented.
