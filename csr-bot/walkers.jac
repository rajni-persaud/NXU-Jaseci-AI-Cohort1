walker talker{
    can use.enc_question, use.enc_answer;

    has utterance;

    current_intents = [];

    main_intents = [
        "website",
        "mobile app",
        "info system",
        "back",
        "bye"
    ];

    website_intents = [
        "one page", 
        "5-page", 
        "custom", 
        "back",
        "bye"
    ];

    mobile_app_intents = [
        "game", 
        "social", 
        "custom", 
        "back",
        "bye"
    ];

    info_system_intents = [
        "back",
        "bye"
    ];

    state {

        if (here.title == "Main"): current_intents = main_intents;
        if (here.title == "Website"): current_intents = website_intents;
        if (here.title == "Mobile App"): current_intents = mobile_app_intents;
        if (here.title == "Information systems"): current_intents = info_system_intents;

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

        if(user_intent == "bye"): disengage;

        take -[transition(intent == user_intent)]-> node::state else {
            take here;
        std.out(current_intents);
        }
    }
}