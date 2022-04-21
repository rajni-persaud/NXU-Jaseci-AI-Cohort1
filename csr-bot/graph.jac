node state{
    has name;
    has title;
    has message;
}

edge transition{
    has intent;
}

graph main_graph {
    has anchor main_root;

    spawn{
        all_nodes = []; // This list will contain all nodes
        # ---------------------   MAIN ROOT  -----------------------------
        main_root = spawn node::state(
                        name = "main",
                        title = "Main",
                        message = "Hi, How can I help you today?"
                    );          // created main root node
        
        all_nodes.list::append(main_root); // added main_root node to all nodes list
        # ---------------------   MAIN ROOT  -----------------------------

        # ---------------------   GENERAL NODES  -----------------------------
        // These are nodes that the user will reach at some point, no matter which path they take.
        thank_you_node = spawn node::state(name = "thank_you", title="thank you", message="Thank you! What else can we help you with?");
        all_nodes.list::append(thank_you_node); // added thank_you node to all nodes list

        payment_node = spawn node::state(name = "payment", title="payment", message="Please send an email to operations@v75inc.com requesting a quotation.");
        all_nodes.list::append(payment_node); // added payment node to all nodes list

        meeting_node = spawn node::state(name = "meeting", title="Meeting Prompt", message="If you'd like, We'll be happy to set up a meeting with one of our developers.");
        all_nodes.list::append(meeting_node); // added meeting node to all nodes list

        email_node = spawn meeting_node -[transition(intent="yes")]-> node::state(
                        name = "email",
                        title = "Email Prompt",
                        message = "Please provide an email so that we can make contact with you. Alternatively, you can contact us at: operations@v75inc.com"
                    );
        
        all_nodes.list::append(email_node); // added email node to all nodes list
        
        meeting_node -[transition(intent="no")]-> thank_you_node;
        
        email_node -[transition(intent="thank_you")]-> thank_you_node;
        payment_node -[transition(intent="pay")]-> thank_you_node;

        about_us_node = spawn node::state(name = "about_us", title="About us", message="This is the about node.");
        all_nodes.list::append(about_us_node); // added about node to all nodes list

        contact_node = spawn node::state(name = "contact_us", title="contact", message="This is the contact node.");
        all_nodes.list::append(contact_node); // added contact node to all nodes list

        bye_node = spawn node::state(name = "goodbye", title="Goodbye", message="I'm always happy to help. Stay safe!");
        # ---------------------   GENERAL NODES  ----------------------------

        # ---------------------   WEBSITE-RELATED NODES  ------------------------
        website = spawn main_root -[transition(intent="website")]-> node::state(
                        name = "website",
                        title = "Website",
                        message = "What kind of website would you like?"
                    );      // created website node

        one_pager = spawn website -[transition(intent="one page")]-> node::state(
                        name = "one_pager",
                        title = "Website Description",
                        message = "What would your one-page website be based on?"
                    );

        five_pager = spawn website -[transition(intent="5-page")]-> node::state(
                        name = "five_pager",
                        title = "Website Description",
                        message = "Who are you hoping to target with your 5-page website?"
                    );

        other_website = spawn website -[transition(intent="custom")]-> node::state(
                        name = "other_website",
                        title = "Website Description",
                        message = "What features are you looking to include on your custom website?"
                    );
        
        website_nodes =[one_pager, five_pager, other_website];  // This list contains all node connected to website node
        for i in website_nodes {
            all_nodes.list::append(i);      // added website nodes to all nodes list
            website <-[transition(intent="back")]- i;   // create edge from each website_node back to website
            i -[transition(intent="meeting")]-> meeting_node; // create edge to meeting node
            i <-[transition(intent=i.name+"_back")]- meeting_node;  // create edge from meeting node to each of website_nodes
        }
        # ---------------------   WEBSITE-RELATED NODES  ------------------------
        
        # ---------------------   MOBILE APP-RELATED NODES  ------------------------
        mobile_app = spawn main_root -[transition(intent="mobile app")]-> node::state(
                        name = "mobile_app",
                        title = "Mobile App",
                        message = "What kind of mobile app would you like?"
                    );
        
        gaming = spawn mobile_app -[transition(intent="game")]-> node::state(
                        name = "gaming",
                        title = "Mobile Description",
                        message = "Here's a sample of a game built by us: https://v75inc.com/gaming"
                    );

        social = spawn mobile_app -[transition(intent="social")]-> node::state(
                        name = "social",
                        title = "Mobile Description",
                        message = "Here's a sample of a social app built by us: https://www.trueselph.com/"
                    );

        other_mobile_app = spawn mobile_app -[transition(intent="custom")]-> node::state(
                        name = "other_mobile_app",
                        title = "Mobile Description",
                        message = "Here's a sample of a custom app built by us: https://www.zeroshotbot.com/"
                    );
        
        mobile_app_nodes =[gaming, social, other_mobile_app];   // This list contains all node connected to mobile_app node
        for i in mobile_app_nodes {
            all_nodes.list::append(i);      // added mobile nodes to all nodes list
            mobile_app <-[transition(intent="back")]- i;   // create edge from each mobile_app_node back to mobile_app
            i -[transition(intent="meeting")]-> meeting_node; // create edge to meeting node
        }
        # ---------------------   MOBILE APP-RELATED NODES  ------------------------

        # ---------------------   INFO SYSTEM-RELATED NODES  ------------------------
        info_system = spawn main_root -[transition(intent="information systems")]-> node::state(
                        name = "info_system",
                        title = "Information systems",
                        message = "Tell me about the information system you'd like."
                    );
        
        educational_is = spawn info_system -[transition(intent="education")]-> node::state(
                        name = "educational_is",
                        title = "IS Description",
                        message = "Here's a sample of a LMS built by us: https://v75inc.com/lms"
                    );

        hr_is = spawn info_system -[transition(intent="human resources")]-> node::state(
                        name = "hr_is",
                        title = "IS Description",
                        message = "Here's a sample of a HRMS built by us: https://v75inc.com/hrms"
                    );

        financial_is = spawn info_system -[transition(intent="financial")]-> node::state(
                        name = "financial_is",
                        title = "IS Description",
                        message = "Here's a sample of a banking system built by us: https://v75inc.com/banking"
                    );

        logistics_mis = spawn info_system -[transition(intent="logistics")]-> node::state(
                        name = "logistics_mis",
                        title = "IS Description",
                        message = "Here's a sample of a logistics MIS system built by us: https://v75inc.com/logistics-mis"
                    );

        custom_is = spawn info_system -[transition(intent="custom")]-> node::state(
                        name = "custom_is",
                        title = "IS Description",
                        message = "Here's a sample of a custom information system built by us: https://v75inc.com/info-system"
                    );
        
        info_system_nodes = [educational_is, hr_is, financial_is, logistics_mis, custom_is]; // This list contains all node connected to info_system node
        for i in info_system_nodes {
            all_nodes.list::append(i);      // added info_system nodes to all nodes list
            info_system <-[transition(intent="back")]- i;   // create edge from each info_system node back to info_system
            i -[transition(intent="meeting")]-> meeting_node; // create edge to meeting node
        }

        # ---------------------   INFO SYSTEM-RELATED NODES  ------------------------

        main_root_nodes =[website, mobile_app, info_system]; // This list contains all node connected to main_root
        for i in main_root_nodes {
            all_nodes.list::append(i); // added main_root nodes to all nodes list
            main_root <-[transition(intent="back")]- i; // created edge from each main_root node back to main root
        }

        // connecting thank_you_node to main_root nodes, so that user can ask questions again
        thank_you_node -[transition(intent="website")]-> main_root_nodes[0];
        thank_you_node -[transition(intent="mobile app")]-> main_root_nodes[1];
        thank_you_node -[transition(intent="information systems")]-> main_root_nodes[2];

        for n in all_nodes: n -[transition(intent="payment")]-> payment_node;   // created edge from each node to payment node.
        for n in all_nodes: n -[transition(intent="goodbye")]-> bye_node;   // created edge from each node to bye_node, allowing the user to exit at any point
    }

}