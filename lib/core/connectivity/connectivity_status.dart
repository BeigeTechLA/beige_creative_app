/// Domain-level connectivity state.
///
/// `unknown` is the first-frame default before the connectivity stream emits.
/// Treated as "do nothing" by the router gate so cold-start doesn't false-block
/// navigation before the first real sample arrives.
enum ConnectivityStatus { online, offline, unknown }
