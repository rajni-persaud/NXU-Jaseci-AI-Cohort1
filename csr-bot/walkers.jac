walker talker{
    can use.enc_question, use.enc_answer;

    has utterance;

    current_intents = [];

    main_intents = [
        "website",
        "mobile app",
        "information systems",
        "back",
        "goodbye"
    ];

    website_intents = [
        "one page", 
        "5-page", 
        "other", 
        "back",
        "goodbye"
    ];

    mobile_app_intents = [
        "game", 
        "social", 
        "other", 
        "back",
        "goodbye"
    ];

    info_system_intents = [
        "back",
        "goodbye"
    ];

    default_intents = [
        "back",
        "goodbye"
    ];

    state {

        current_intents = default_intents;

        if (here.title == "Main"): current_intents = main_intents;
        if (here.title == "Website"): current_intents = website_intents;
        if (here.title == "Mobile App"): current_intents = mobile_app_intents;
        if (here.title == "Information systems"): current_intents = info_system_intents;

        if(here.title == "Goodbye"){
            std.out(here.message);
            disengage;
        }

        std.out(here.message);

        utterance = std.input("> ");

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

        std.out("Current intents to choose from: ", current_intents);
        std.out("Intent from user: ", user_intent);

        take -[transition(intent == user_intent)]-> node::state else {
            take here;
        }
    }
}