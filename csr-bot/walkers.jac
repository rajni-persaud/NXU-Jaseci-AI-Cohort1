walker talker{
    can use.enc_question, use.enc_answer;

    has utterance;
    has prev_nodes = []; // This varible will store the previous node the walker has been on before take(-meetings)

    website_nodes_names =["one_pager", "five_pager", "other_website"];
    mobile_nodes_names = ["social", "gaming", "other_mobile_app"];
    info_system_node_names = ["educational_is", "hr_is", "financial_is", "logistics_mis", "custom_is"];
    
    current_intents = [];
    about_intents = ["about", "what does v75 do", "what do you do"];
    contact_intents = ["contact", "how can I contact v75", "where is v75 located", "where are you located", "telephone number"];

    main_intents = [
        "website",
        "mobile app",
        "information systems",
        "payment",
        "back",
        "goodbye"
    ];

    website_intents = [
        "one page", 
        "5-page", 
        "custom",
        "payment",
        "back",
        "goodbye"
    ];

    mobile_app_intents = [
        "game", 
        "social", 
        "custom",
        "payment",
        "back",
        "goodbye"
    ];

    info_system_intents = [
        "education",
        "human resources",
        "financial",
        "logistics",
        "custom",
        "back",
        "payment",
        "goodbye"
    ];

    website_description_intents = [
        "financial",
        "hr",
        "marketing",
        "personal",
        "custom",
        "back"
    ];

        yes_no_intents = [
        "yes",
        "yeah",
        "yes please",
        "of course",
        "absolutely",
        "I'd like that",
        "negative",
        "no",
        "not",
        "back",
        "goodbye"
    ];
    
    default_intents = [
        "back",
        "payment",
        "goodbye"
    ];

    work_samples = {
        'web_financial':'https://v75inc.com/finance',
        'web_hr':'https://v75inc.com/team',
        'web_marketing':'https://v75inc.com/marketing',
        'web_personal':'https://eldonmarks.com/',
        'web_custom':'https://v75inc.com/'
    };

    state {
        for a in about_intents{
            main_intents.list::append(a);
            website_intents.list::append(a);
            mobile_app_intents.list::append(a);
            info_system_intents.list::append(a); 
            default_intents.list::append(a); 
        }

        for c in contact_intents{
            main_intents.list::append(c);
            website_intents.list::append(c);
            mobile_app_intents.list::append(c);
            info_system_intents.list::append(c); 
            default_intents.list::append(c); 
        }

        current_intents = default_intents;

        if (here.title in ["Main", "thank you", "About us", "contact"]): current_intents = main_intents;
        if (here.title == "Website"): current_intents = website_intents;
        if (here.title == "Mobile App"): current_intents = mobile_app_intents;
        if (here.title == "Information systems"): current_intents = info_system_intents;
        if (here.title == "Website Description"): current_intents = website_description_intents;
        if (here.title == "Meeting Prompt"): current_intents = yes_no_intents;

        if(here.title == "Goodbye"){
            std.out(here.message);
            disengage;
        }

        std.out(here.message);

        if(here.title not in ["Mobile Description", "IS Description", "payment"]): utterance = std.input("> ");

        q_enc = use.enc_question(utterance);
        a_enc = use.enc_answer(current_intents); # can take lists or single strings

        a_scores=[];

        max_score = 0;

        for i in a_enc:
            a_scores.l::append(vector.cosine_sim(q_enc, i));

        for i in a_scores {
            if i > max_score: 
                max_score = i;
        }

        max_index = a_scores.list::index(max_score);

        user_intent = current_intents[max_index];

        if (here.title == "Meeting Prompt"){
            if user_intent in ["yes", "yes please", "yeah", "of course", "absolutely", "I'd like that"]: user_intent = "yes";
            if user_intent in ["negative", "no", "not"]: user_intent = "no";
            if (user_intent != "no" or user_intent != "yes"): if utterance.str::lower == "yes": user_intent = "yes";
        }

        std.out("-------------------------------------------------");
        std.out("message:", here.message);
        std.out("utterance:", utterance);
        std.out("here.title: ", here.title);
        std.out("here.name: ", here.name);
        std.out("Current intents to choose from: ", current_intents);
        std.out("Intent from user: ", user_intent);
        std.out("-------------------------------------------------");
         
        if (here.name != "meeting"): prev_nodes.list::append(here.name);
        std.out(prev_nodes);
        
        if(here.title == "Website Description" and user_intent != "back"){
            web_sample_link = work_samples['web_'+user_intent];
            take -[transition(intent=="meeting")]-> node::state;
            std.out("Here's a sample of a",user_intent,"website built by us:",web_sample_link);
        }
        elif(here.title == "Mobile Description"): take -[transition(intent=="meeting")]-> node::state;
        elif(here.title == "IS Description"): take -[transition(intent=="meeting")]-> node::state;
        elif(here.title == "Email Prompt"): take -[transition(intent == "thank_you")]-> node::state;
        elif(here.title == "payment"): take -[transition(intent == "pay")]-> node::state;
            else{
                if (user_intent in about_intents): user_intent = "about-us";
                if (user_intent in contact_intents): user_intent = "contact-us";
                if (user_intent == "back" and here.name == "meeting" and prev_nodes[-1] in website_nodes_names): user_intent = prev_nodes[-1]+"_back";
                if (user_intent == "back" and here.name == "meeting" and prev_nodes[-1] in mobile_nodes_names): user_intent = "mobile_app_back";
                if (user_intent == "back" and here.name == "meeting" and prev_nodes[-1] in info_system_node_names): user_intent = "info_system_back";
                take -[transition(intent == user_intent)]-> node::state else: take here;
        } 
    }
}