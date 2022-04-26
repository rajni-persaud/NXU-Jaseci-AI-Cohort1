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
    for a in about_intents: current_intents.list::append(a);
    contact_intents = ["contact", "how can I contact v75", "where is v75 located", "where are you located", "telephone number"];
    for a in contact_intents: current_intents.list::append(a);
    main_intents = ["website", "mobile app", "information systems", "back", "goodbye"];
    for a in main_intents: current_intents.list::append(a);
    website_intents = ["one page", "5-page", "custom"];
    for a in website_intents: current_intents.list::append(a);
    mobile_app_intents = ["game", "social", "custom"];
    for a in mobile_app_intents: current_intents.list::append(a);
    info_system_intents = ["education", "human resources", "financial", "logistics", "custom"];
    for a in info_system_intents: current_intents.list::append(a);
    website_description_intents = ["financial", "hr", "marketing", "personal", "custom"];
    for a in website_description_intents: current_intents.list::append(a);
    yes_no_intents = ["yes", "yeah", "yes please", "of course", "absolutely", "I'd like that", "negative", "no", "not"];
    for a in yes_no_intents: current_intents.list::append(a);
    payment_intents = ["how much will it cost", "what is the price", "how much do I owe you", "how much money should I pay for this"];
    for a in payment_intents: current_intents.list::append(a);
    personal_intents = ["about me", "my life", "family"];
    for a in personal_intents: current_intents.list::append(a);

    intents_list = ["website", "mobile app", "information systems", "one page", "5-page", "game", "social"];
    node_name_list = ["website", "mobile_app", "info_system", "one_pager", "five_pager", "gaming", "social"];

    state {
        if(here.title == "Goodbye"){
            std.out(here.message);
            disengage;
        }

        std.out(here.message);

        if(here.title not in ["Website Description", "Mobile Description", "IS Description", "payment"]): utterance = std.input("> ");

        # ----------------  Using USE to find the highest intent  ---------------
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
    # ----------------  Using USE to find the highest intent  ---------------

    # ---------------------  Breaking up utterance  ------------------------
     u_word = utterance.str::split;
     mini_utterance = [];
     mini = "";
     num = 1;
     for i in u_word {
        mini = mini + " " + i;
        num = num + 1;

        if num == 3{
            mini_utterance.list::append(mini);
            num = 1;
            mini = "";
        }
    }
    if u_word[-1] not in mini_utterance[-1]: mini_utterance.list::append(u_word[-1]);
    std.out(mini_utterance);
    # ---------------------  Breaking up utterance  ------------------------
    # ---------------------  Using USE to find the intent of mini_utterrance  ------------------------
    mni_intents = [];
    for u in mini_utterance{
        mini_q_enc = use.enc_question(u);
        mini_a_enc = use.enc_answer(current_intents); # can take lists or single strings

        mini_a_scores=[];

        mini_max_score = 0;

        for i in mini_a_enc:
            mini_a_scores.l::append(vector.cosine_sim(mini_q_enc, i));

        for i in mini_a_scores {
            if i > mini_max_score: 
                mini_max_score = i;
        }

        mini_max_index = mini_a_scores.list::index(mini_max_score);

        mini_user_intent = current_intents[mini_max_index];

        mni_intents.list::append(mini_user_intent);
    }
    std.out(mni_intents);
    # ---------------------  Using USE to find the intent of mini_utterrance  ------------------------


        if (here.title == "Meeting Prompt"){
            if user_intent in ["yes", "yes please", "yeah", "of course", "absolutely", "I'd like that"]: user_intent = "yes";
            if user_intent in ["negative", "no", "not"]: user_intent = "no";
            if (user_intent != "no" or user_intent != "yes"): if utterance.str::lower == "yes": user_intent = "yes";
        }

        // std.out("-------------------------------------------------");
        // std.out("message:", here.message);
        // std.out("utterance:", utterance);
        // std.out("here.title: ", here.title);
        // std.out("here.name: ", here.name);
        // std.out("Current intents to choose from: ", current_intents);
        // std.out("Intent from user: ", user_intent);
        // std.out("-------------------------------------------------");
         
        user_path.list::append(here.name);
        // std.out(user_path);
        // std.out(user_path.length);
        intent_path.list::append(user_intent);
        // std.out(intent_path);
        // std.out(intent_path.length)

        # ---------------------  Handling only 1 intent  ------------------------
        if here.title in ["Website", "one_pager", "five_pager", "other_website"] and user_intent in personal_intents: user_intent = "personal";
        if here.title in ["Website", "one_pager", "five_pager", "other_website"] and user_intent in website_description_intents{
            if user_intent in ["financial", "marketing", "personal", "custom"]: user_intent = "web_"+user_intent;
            if user_intent in ["hr", "human resources"]: user_intent = "web_hr";
        }

        if here.title == "Information systems" and user_intent in info_system_intents{
            user_intent_index = info_system_intents.list::index(user_intent);
            user_intent = info_system_node_names[user_intent_index];
        }

        if user_intent in intents_list{
            user_intent_index = intents_list.list::index(user_intent);
            user_intent = node_name_list[user_intent_index];
        }
        # ---------------------  Handling only 1 intent  ------------------------

        if(here.title in ["Website Description", "Mobile Description", "IS Description"]): take -[transition(intent=="from_"+here.name+"_to_meeting")]-> node::state;
        elif(here.title == "Email Prompt" and user_intent != "back"): take -[transition(intent == "thank_you")]-> node::state;
        elif(here.title == "payment"): take -[transition(intent == "pay")]-> node::state;
            else{
                if (user_intent in about_intents): user_intent = "about_us";
                if (user_intent in contact_intents): user_intent = "contact_us";
                if (user_intent in payment_intents): user_intent = "payment";
                count_b = 2;
                back_num = 0;
                # ind = 0;
                back_index = 1;
                // std.out("user_path_count_b", user_path[user_path.length-count_b]);
                if(user_path[user_path.length-count_b] in ["web_financial", "web_hr", "web_marketing", "web_personal", "web_custom", "meeting"]): count_b = count_b + 1;
                while(intent_path[intent_path.length-back_index] == "back"){
                    back_num = back_num + 1;
                    back_index = back_index + 1;
                }
                // std.out("back_num : ", back_num);
                // std.out("count_b : ", count_b);
                if back_num > 1: count_b = count_b + back_num;
                if back_num > 2: count_b = count_b + back_num - 1;
                if (user_intent not in ["back", "goodbye", "yes", "no"]): user_intent = "from_"+here.name+"_to_"+user_intent;
                // std.out(user_intent);
                if (user_intent == "back"): user_intent = "back_"+user_path[user_path.length-count_b];
                # report{"utterance":utterance, "user_intent":user_intent, "scores":a_scores};
                take -[transition(intent == user_intent)]-> node::state else: take here;
        } 
    }
}