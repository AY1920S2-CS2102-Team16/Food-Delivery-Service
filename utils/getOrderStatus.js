const getOrderStatus = function (order) {
    let status, isPaid;
    if (order.time_depart === null) {
        status = "Rider departing";
    } else if (order.time_collect === null) {
        status = "Rider collecting";
    } else if (order.time_leave === null) {
        status = "Rider collected";
    } else if (order.time_delivered === null) {
        status = "Rider delivering";
    } else {
        status = "Delivered";
    }

    isPaid = (order.time_paid !== null) ? "Paid" : "Unpaid";

    return [status, isPaid];
};

module.exports = getOrderStatus;
