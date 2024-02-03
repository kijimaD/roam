import networkx as nx
import pathlib
import sqlite3

def to_rellink(inp: str) -> str:
    return pathlib.Path(inp).stem


def build_graph() -> any:
    """Build a graph from the org-roam database."""
    graph = nx.DiGraph()

    graph = process_db(graph, "./")
    graph = process_db(graph, "./denote/")

    return graph

def process_db(graph: any, pathprefix: str) -> any:
    """pathprefix は/で終わらせること"""
    conn = sqlite3.connect(pathprefix+"org-roam.db")

    # Query all nodes first
    nodes = conn.execute("SELECT file, id, title FROM nodes WHERE level = 0;")
    # A double JOIN to get all nodes that are connected by a link
    links = conn.execute("SELECT n1.id, nodes.id FROM ((nodes AS n1) "
                         "JOIN links ON n1.id = links.source) "
                         "JOIN (nodes AS n2) ON links.dest = nodes.id "
                         "WHERE links.type = '\"id\"';")
    # Populate the graph
    graph.add_nodes_from((n[1], {
        "label": n[2].strip("\""),
        "tooltip": n[2].strip("\""),
        "lnk": pathprefix+to_rellink(n[0]),
        "id": n[1].strip("\"")
    }) for n in  nodes)
    graph.add_edges_from(n for n in links if n[0] in graph.nodes and n[1] in graph.nodes)
    conn.close()
    return graph
