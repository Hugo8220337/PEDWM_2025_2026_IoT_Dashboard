import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static GraphQLClient initializeClient() {
    
    const String graphQLUrl = String.fromEnvironment(
      'GRAPHQL_URL', 
      defaultValue: 'http://127.0.0.1:8088/graphql',
    );

    // link for Queries and Mutations (HTTP)
    final HttpLink httpLink = HttpLink(graphQLUrl);

    // Convert 'http://...' to 'ws://...'
    final String wsUrl =
        '${graphQLUrl.replaceFirst('http', 'ws')}/ws';

    // WebSocket for Subscriptions
    final WebSocketLink wsLink = WebSocketLink(
      wsUrl,
      config: const SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    // combine both links, directing operations to the correct one based on their type (query/mutation or subscription)
    final Link link = Link.split(
      (request) => request.isSubscription,
      wsLink,
      httpLink,
    );

    return GraphQLClient(
      cache: GraphQLCache(), // Automatic caching with normalized data
      link: link,
    );
  }
}
