import React, { useState } from "react";
import PosCart from "./PosCart";

export default function CustomerPosView({ orders, onCheckout }) {
  const [isPopupOpen, setIsPopupOpen] = useState(false);

  const handleCheckoutClick = () => {
    if (orders) {
      setIsPopupOpen(true);
    }
  };

  const handlePaymentSelection = (method) => {
    setIsPopupOpen(false);
    onCheckout(method, orders);
  };

  const handleClosePopup = () => {
    setIsPopupOpen(false);
  };

  const formatTimestamp = (timestamp) => {
    return new Date(timestamp * 1000).toLocaleString();
  };

  return (
    <div className="customer-view">
      {/* Order Details */}
      <div className="order-details">
        {orders ? (
          <>
            <p
              style={{
                fontFamily: "Oswald",
                fontSize: "1.5vh",
                color: "white",
              }}
            >
              <strong>Time:</strong> {formatTimestamp(orders.timestamp)}
            </p>
            <PosCart
              cart={orders.cart}
              total={orders.total}
              discount={orders.discount}
              setDiscount={() => {}} // No-op for customers
              updateQuantity={() => {}} // Disable quantity changes
              removeFromCart={() => {}} // Disable removing items
              readOnly={true} // Indicate customer view
            />
            <div style={{ marginTop: "1vh" }}>
              <button
                onClick={handleCheckoutClick}
                disabled={!orders}
                className={`customer-checkoutbutton ${
                  !orders
                    ? "customer-checkoutbuttondisabled"
                    : "customer-checkoutbutton"
                }`}
              >
                Complete Checkout
              </button>
            </div>
          </>
        ) : (
          <p className="customer-waiting">
            No pending order available. Waiting for employee to prepare an
            order...
          </p>
        )}
      </div>

      {/* Payment Method Popup */}
      {isPopupOpen && (
        <div className="checkout-popup-root">
          <div className="checkout-popup">
            <h3 className="checkout-popup-header">Select Payment Method</h3>
            <button
              onClick={() => handlePaymentSelection("cash")}
              className="checkout-cash-button"
            >
              Cash
            </button>
            <button
              onClick={() => handlePaymentSelection("bank")}
              className="checkout-bank-button"
            >
              Bank
            </button>
            <button
              onClick={handleClosePopup}
              className="checkout-payment-cancelbtn"
            >
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
