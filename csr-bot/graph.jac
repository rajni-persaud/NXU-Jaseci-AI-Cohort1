node state{
    has title;
    has message;
    has prompts;
}

edge transition{
    has intent;
}

graph main_graph {
    has anchor main_root;

    spawn{
        main_root = spawn node::state(
                        title = "Main",
                        message = "Hi, How can I help you today?",
                        prompts = ["website", "mobile app", "information systems", "quit"]
                    );

        website = spawn main_root -[transition(intent="website")]-> node::state(
                        title = "Website",
                        message = "Type of website?",
                        prompts = ["one page", "5-page", "custom", "back"]
                    );

        mobile_app = spawn main_root -[transition(intent="mobile app")]-> node::state(
                        title = "Mobile App",
                        message = "Type of mobile app?",
                        prompts = ["game", "social", "custom", "back"]
                    );

        info_system = spawn main_root -[transition(intent="information systems")]-> node::state(
                        title = "Information systems",
                        message = "Tell me about the information system you'd like.",
                        prompts = ["back"]
                    );
        
        
        bye_node = spawn node::state(title="Goodbye", message="I'm always happy to help. Stay safe!", prompts="");

        all_nodes = [main_root];

        main_root_nodes =[website, mobile_app, info_system];
        for i in main_root_nodes {
            all_nodes.list::append(i);
            main_root <-[transition(intent="back")]- i;
        }

        website_nodes =[];
        mobile_app_nodes =[];
        info_system_nodes = [];

        for n in all_nodes: n -[transition(intent="goodbye")]-> bye_node;
    }

}