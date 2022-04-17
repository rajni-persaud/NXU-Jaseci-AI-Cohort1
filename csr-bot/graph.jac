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
                        message = "What kind of website would you like?",
                        prompts = ["one page", "5-page", "custom", "back"]
                    );

        one_pager = spawn website -[transition(intent="one page")]-> node::state(
                        title = "One Pager Website Details",
                        message = "What would your one-page website be based on?",
                        prompts = ["back"]
                    );

        five_pager = spawn website -[transition(intent="5-page")]-> node::state(
                        title = "Five Pager Website Details",
                        message = "Who are you hoping to target with your 5-page website?",
                        prompts = ["back"]
                    );

        other_website = spawn website -[transition(intent="other")]-> node::state(
                        title = "Custom Website Details",
                        message = "What features are you looking to include on your custom website?",
                        prompts = ["back"]
                    );

        // one_pager_users = spawn website -[transition(intent="one page")]-> node::state(
        //                 title = "One Pager Website Details",
        //                 message = "What would your one-page website be based on?",
        //                 prompts = ["back"]
        //             );

        mobile_app = spawn main_root -[transition(intent="mobile app")]-> node::state(
                        title = "Mobile App",
                        message = "What kind of mobile app would you like?",
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

        website_nodes =[one_pager, five_pager, other_website];
        for i in website_nodes {
            all_nodes.list::append(i);
            website <-[transition(intent="back")]- i;
        }

        mobile_app_nodes =[];
        info_system_nodes = [];

        for n in all_nodes: n -[transition(intent="goodbye")]-> bye_node;
    }

}