const getOrderStatus = function (order) {
    let status, isPaid;
    if (order.time_depart === null) {
        status = "Pending confirmation";
    } else if (orders[i].time_collect === null) {
        status = "Rider picking up";
    } else if (orders[i].time_leave === null) {
        status = "Rider delivering";
    } else {
        status = "Delivered";
    }

    isPaid = (order.time_paid !== null) ? "Paid" : "Unpaid";

    return [status, isPaid];
};

module.exports = getOrderStatus;
