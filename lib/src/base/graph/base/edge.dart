abstract interface class Edge<N> {
  List<N> getAdjacentNodes();
  bool isConnected(N node);
}
