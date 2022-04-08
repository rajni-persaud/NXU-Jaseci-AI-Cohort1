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
    services_node = spawn here --> node::intent(name="Services");
    promotions_node = spawn here --> node::intent(name="Promotions");
    covid_node = spawn here --> node::intent(name="Covid-related info");
    details_node = spawn appointment_node --> node::intent(name="Appointment Details");
    more_details_node = spawn details_node --> node::intent(name="More Details required");
    cancel_node = spawn details_node --> node::intent(name="Cancel Appointment");
    schedule_node = spawn details_node --> node::intent(name="Schedule Appointment");
    reschedule_node = spawn details_node --> node::intent(name="Reschedule Appointment");
    gift_node = spawn details_node --> node::intent(name="Gift Appointment");
    refund_node = spawn cancel_node --> node::intent(name="Refund Appointment");
    discount_node = spawn promotions_node --> node::intent(name="Discounts");
    special_occasions = spawn services_node --> node::intent(name="Special Occasions");
    goodbye_node = spawn node::intent(name="Goodbye");
    cancel_node --> refund_node;
    cancel_node --> reschedule_node;
    refund_node --> payment_node;
    appointment_node --> payment_node;
    customers_node --> appointment_node;
    discount_node --> payment_node;
    discount_node --> special_occasions;
    services_node --> payment_node;
    services_node --> appointment_node;
    details_node <--> more_details_node;
    goodbye_node --> here;
    node_bye = [info_node, customers_node, appointment_node, payment_node, services_node,
                promotions_node, covid_node, details_node, more_details_node, cancel_node,
                schedule_node, reschedule_node, gift_node, refund_node, discount_node, 
                special_occasions]; //all nodes connected to goodbye node
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