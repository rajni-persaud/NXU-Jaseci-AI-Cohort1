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
                        title = "Greeting",
                        message = "Hi, How can I help you today?",
                        prompts = ["website", "mobile app", "information systems", "quit"]
                    );
        
        website = spawn main_root -[transition(intent="website")]-> node::state(
                        title = "Website",
                        message = "Type of website?",
                        prompts = ["one page", "5-page", "custom", "back"]
                    );

        website -[transition(intent="back")]-> main_root;

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
    }

}