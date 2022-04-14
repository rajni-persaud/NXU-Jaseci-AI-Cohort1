# 2.2.6 Navigating Graphs with Walkers 

node state {
    has response="I visited the state node! -  ";
}

node hop_state;

edge hop;

walker init{
    has state_visits=0, hop_state_visits=0, save_root;

    root{
        save_root = here;
        hop1 = spawn here -[hop]-> node::hop_state;
        hop2 = spawn here -[hop]-> node::hop_state;
    }

}