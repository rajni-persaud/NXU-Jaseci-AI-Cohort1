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
        all_nodes = []; // This list will contain all nodes
        main_root = spawn node::state(
                        title = "Main",
                        message = "Hi, How can I help you today?",
                        prompts = ["website", "mobile app", "information systems", "quit"]
                    );          // created main root node
        
        all_nodes.list::append(main_root); // added main_root node to all nodes list

        website = spawn main_root -[transition(intent="website")]-> node::state(
                        title = "Website",
                        message = "What kind of website would you like?",
                        prompts = ["one page", "5-page", "custom", "back"]
                    );      // created website node

        one_pager = spawn website -[transition(intent="one page")]-> node::state(
                        title = "Website Description",
                        message = "What would your one-page website be based on?",
                        prompts = ["back"]
                    );

        five_pager = spawn website -[transition(intent="5-page")]-> node::state(
                        title = "Website Description",
                        message = "Who are you hoping to target with your 5-page website?",
                        prompts = ["back"]
                    );

        other_website = spawn website -[transition(intent="other")]-> node::state(
                        title = "Website Description",
                        message = "What features are you looking to include on your custom website?",
                        prompts = ["back"]
                    );

        meeting_node = spawn node::state(title="Meeting Prompt", message="If you'd like, We'll be happy to set up a meeting with one of our developers.");

        email_node = spawn meeting_node -[transition(intent="yes")]-> node::state(
                        title = "Email Prompt",
                        message = "Please provide an email so that we can make contact with you. Alternatively, you can contact us at: operations@v75inc.com",
                        prompts = ["back"]
                    );
        
        meeting_node -[transition(intent="no")]-> main_root;
        
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
        
        bye_node = spawn node::state(title="Goodbye", message="I'm always happy to help. Stay safe!");

        main_root_nodes =[website, mobile_app, info_system]; // This list contains all node connected to main_root
        for i in main_root_nodes {
            all_nodes.list::append(i); // added main_root nodes to all nodes list
            main_root <-[transition(intent="back")]- i; // created edge from each main_root node back to main root
        }

        website_nodes =[one_pager, five_pager, other_website];  // This list contains all node connected to website node
        for i in website_nodes {
            all_nodes.list::append(i);      // added website nodes to all nodes list
            website <-[transition(intent="back")]- i;   // create edge from each website_node back to website
            i -[transition(intent="")]-> meeting_node; // create edge that shows the user a sample choosing topic of website
        }

        website <-[transition(intent="back")]- meeting_node;

        mobile_app_nodes =[];   // This list contains all node connected to mobile_app node
        info_system_nodes = []; // This list contains all node connected to info_system node

        for n in all_nodes: n -[transition(intent="goodbye")]-> bye_node;   // created edge from each node to bye_node, allowing the user to exit at any point
    }

}