// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SubscriptionService {
    struct Subscription {
        uint256 amount;
        uint256 nextPaymentDue;
        bool active;
    }

    mapping(address => Subscription) public subscriptions;

    event Subscribed(address indexed user, uint256 amount, uint256 nextPaymentDue);
    event PaymentMade(address indexed user, uint256 amount);
    event Unsubscribed(address indexed user);

    function subscribe(uint256 _durationInDays) external payable {
        require(msg.value > 0, "Payment must be greater than zero");
        require(!subscriptions[msg.sender].active, "Already subscribed");

        uint256 nextPayment = block.timestamp + (_durationInDays * 1 days);
        subscriptions[msg.sender] = Subscription({
            amount: msg.value,
            nextPaymentDue: nextPayment,
            active: true
        });

        emit Subscribed(msg.sender, msg.value, nextPayment);
    }

    function pay() external payable {
        require(subscriptions[msg.sender].active, "No active subscription");
        require(msg.value > 0, "Payment must be greater than zero");

        subscriptions[msg.sender].nextPaymentDue += 30 days;
        emit PaymentMade(msg.sender, msg.value);
    }

    function unsubscribe() external {
        require(subscriptions[msg.sender].active, "No active subscription");
        
        delete subscriptions[msg.sender];
        emit Unsubscribed(msg.sender);
    }

    function getSubscriptionInfo() external view returns (uint256, uint256, bool) {
        Subscription memory subscription = subscriptions[msg.sender];
        return (subscription.amount, subscription.nextPaymentDue, subscription.active);
    }
}
