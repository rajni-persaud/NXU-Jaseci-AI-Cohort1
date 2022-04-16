node intent: has name;
walker get_names{
    std.out(here.name);
    take -->;
}

walker build_example{
    greeting_node = spawn here --> node::intent(name="Greeting");
    website_node = spawn greeting_node --> node::intent(name="website");
    mobile_app_node = spawn greeting_node --> node::intent(name="mobile app");
    info_systems_node = spawn greeting_node --> node::intent(name="info systems");
    one_page_node = spawn website_node --> node::intent(name="one_page_node");
    five_page_node = spawn website_node --> node::intent(name="five_page_node");
    custom_web = spawn website_node --> node::intent(name="custom_web");
    social_node = spawn mobile_app_node --> node::intent(name="social_node");
    game_node = spawn mobile_app_node --> node::intent(name="game_node");
    custom_mobile = spawn mobile_app_node --> node::intent(name="custom_mobile");
    category_web_node = spawn node::intent(name="category_web_node");
    num_users_web_node = spawn node::intent(name="num_users_web_node");
    category_mobile_node = spawn node::intent(name="category_mobile_node");
    num_users_mobile_node = spawn node::intent(name="num_users_mobile_node");

    website_nodes = [one_page_node, five_page_node, custom_web];
    mobile_nodes = [social_node, game_node, custom_mobile];

    for n in website_nodes: n --> category_web_node;
    for n in website_nodes: n --> num_users_web_node;

    for n in mobile_nodes: n --> category_mobile_node;
    for n in mobile_nodes: n --> num_users_mobile_node;

    category_is_node = spawn info_systems_node --> node::intent(name="category_is_node");
    num_users_is_node = spawn info_systems_node --> node::intent(name="num_users_is_node");

    financial_is_node = spawn category_is_node --> node::intent(name="financial_is_node");
    hr_is_node = spawn category_is_node --> node::intent(name="hr_is_node");
    other_is = spawn category_is_node --> node::intent(name="other_is");

    payment_node = spawn node::intent(name="payment_node");

    payments_nodes = [greeting_node, one_page_node, five_page_node, custom_web, social_node, game_node, custom_mobile, category_web_node, num_users_web_node, category_mobile_node, num_users_mobile_node, category_is_node, num_users_is_node, financial_is_node, hr_is_node, other_is];
    
    for n in payments_nodes: n --> payment_node;

    email_node = spawn payment_node --> node::intent(name="email_node");



}

walker init{
    root {
        spawn here walker::build_example;
        // spawn here walker::get_names;
        take -->;
    }
    intent {
        //spawn here walker::get_names;
        // disengage;
    }

    //for i in -->: std.out(i.context);
}