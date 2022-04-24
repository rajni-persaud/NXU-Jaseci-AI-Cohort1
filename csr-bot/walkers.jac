walker talker{
    can use.enc_question, use.enc_answer;

    has utterance;
    has user_path = []; // This varible will store the previous node the walker has been on before take
    has intent_path = [];

    website_nodes_names =["one_pager", "five_pager", "other_website"];
    mobile_nodes_names = ["social", "gaming", "other_mobile_app"];
    info_system_node_names = ["educational_is", "hr_is", "financial_is", "logistics_mis", "custom_is"];
    
    current_intents = [];
    about_intents = ["about", "what does v75 do", "what do you do"];
    contact_intents = ["contact", "how can I contact v75", "where is v75 located", "where are you located", "telephone number"];
    main_intents = ["website", "mobile app", "information systems", "payment", "back", "goodbye"];
    website_intents = ["one page", "5-page", "custom","payment", "back", "goodbye"];
    mobile_app_intents = ["game", "social", "custom", "payment", "back", "goodbye"];
    info_system_intents = ["education", "human resources", "financial", "logistics", "custom", "back", "payment", "goodbye"];
    website_description_intents = ["financial", "hr", "marketing", "personal", "custom", "back"];
    yes_no_intents = ["yes", "yeah", "yes please", "of course", "absolutely", "I'd like that", "negative", "no", "not", "back"];
    default_intents = ["back", "payment", "goodbye"];

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
        if (here.title in website_nodes_names): current_intents = website_description_intents;
        if (here.title == "Meeting Prompt"): current_intents = yes_no_intents;

        if(here.title == "Goodbye"){
            std.out(here.message);
            disengage;
        }

        std.out(here.message);

        if(here.title not in ["Website Description", "Mobile Description", "IS Description", "payment"]): utterance = std.input("> ");

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
         
        user_path.list::append(here.name);
        std.out(user_path);
        std.out(user_path.length);
        intent_path.list::append(user_intent);
        std.out(intent_path);
        std.out(intent_path.length);
        prev_nodes = [];
        
        if(here.title in ["Website Description", "Mobile Description", "IS Description"]): take -[transition(intent=="meeting")]-> node::state;
        elif(here.title == "Email Prompt" and user_intent != "back"): take -[transition(intent == "thank_you")]-> node::state;
        elif(here.title == "payment"): take -[transition(intent == "pay")]-> node::state;
            else{
                if (user_intent in about_intents): user_intent = "about-us";
                if (user_intent in contact_intents): user_intent = "contact-us";
                count_b = 2;
                back_num = 0;
                ind = 0;
                back_index = 1;
                std.out("user_path_count_b", user_path[user_path.length-count_b]);
                if(user_path[user_path.length-count_b] in ["web_financial", "web_hr", "web_marketing", "web_personal", "web_custom", "meeting"]): count_b = count_b + 1;
                while(intent_path[intent_path.length-back_index] == "back"){
                    back_num = back_num + 1;
                    back_index = back_index + 1;
                }
                std.out("back_num : ", back_num);
                std.out("count_b : ", count_b);
                if back_num > 1: count_b = count_b + back_num;
                if back_num > 2: count_b = count_b + back_num - 1;
                if (user_intent == "back"): user_intent = "back_"+user_path[user_path.length-count_b];
                take -[transition(intent == user_intent)]-> node::state else: take here;
        } 
    }
}