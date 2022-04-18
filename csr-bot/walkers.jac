walker talker{
    can use.enc_question, use.enc_answer;

    has utterance;

    current_intents = [];

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
        "back",
        "payment",
        "goodbye"
    ];

    website_description_intents = [
        'financial',
        'hr',
        'marketing',
        'personal',
        'custom'
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
        'web_custom':'https://v75inc.com/',
        'mobile_social':'',
        'mobile_game': '',
        'mobile_custom': '',
        'is_financial':'',
        'is_hr':'',
        'is_custom':''
    };

    state {

        current_intents = default_intents;

        if (here.title == "Main" || here.title == "thank you"): current_intents = main_intents;
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

        if(here.title != "payment"): utterance = std.input("> ");

        if(here.title == "payment"): take -[transition(intent == "pay")]-> node::state;

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

        std.out("message:", here.message);
        std.out("utterance:", utterance);
        std.out("here.title: ", here.title);
        std.out("Current intents to choose from: ", current_intents);
        std.out("Intent from user: ", user_intent);
        
        if(here.title == "Website Description"){
            web_sample_link = work_samples['web_'+user_intent];
            take -[transition(intent=="meeting")]-> node::state;
            std.out("Here's a sample of a",user_intent,"website built by us:",web_sample_link);
        }
        elif(here.title == "Email Prompt"){
            take -[transition(intent == "thank_you")]-> node::state;
        }
        else{
            take -[transition(intent == user_intent)]-> node::state else {
                take here;
            }
        } 
    }
}