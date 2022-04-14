node intent: has name;
walker get_names{
    std.out(here.name);
    take -->;
}

walker build_example{
    info_node = spawn here --> node::intent(name="General Info");
    customers_node = spawn here --> node::intent(name="Customers");
    appointment_node = spawn here --> node::intent(name="Appointments");
    payment_node = spawn here --> node::intent(name="Payments");
    goodbye_node = spawn node::intent(name="Goodbye");
    goodbye_node --> here;
    node_bye = [info_node, customers_node, appointment_node, payment_node];
    for i in node_bye: i --> goodbye_node;
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

    for i in -->: std.out(i.context);
}