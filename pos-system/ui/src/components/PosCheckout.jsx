import React, { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCartShopping,
  faMoneyCheck,
  faTrashCan,
} from "@fortawesome/pro-solid-svg-icons";

const PosCheckout = ({ onCheckout, onSetCheckout, onClearCheckout, cart }) => {
  const [isPopupOpen, setIsPopupOpen] = useState(false);
  const [paymentMethod, setPaymentMethod] = useState(null);

  const handleCheckoutClick = () => {
    if (cart.length > 0) {
      setIsPopupOpen(true);
    }
  };

  const handlePaymentSelection = (method) => {
    setPaymentMethod(method);
    setIsPopupOpen(false);
    onCheckout(method);
  };

  const handleClosePopup = () => {
    setIsPopupOpen(false);
  };

  return (
    <div className="pos-checkoutbuttonroot">
      <button
        onClick={onSetCheckout}
        disabled={cart.length === 0}
        className={`pos-checkoutbutton2 ${
          cart.length === 0
            ? "pos-checkoutbuttondisabled"
            : "pos-checkoutbutton2"
        }`}
      >
        <FontAwesomeIcon icon={faMoneyCheck} style={{ marginRight: "0.5vw" }} />
        <span>Set Checkout</span>
      </button>
      <button
        onClick={onClearCheckout}
        disabled={cart.length === 0}
        className={`pos-clearcheckoutbutton ${
          cart.length === 0
            ? "pos-checkoutbuttondisabled"
            : "pos-clearcheckoutbutton"
        }`}
      >
        <FontAwesomeIcon icon={faTrashCan} style={{ marginRight: "0.5vw" }} />
        <span>Clear Checkout</span>
      </button>
    </div>
  );
};

export default PosCheckout;
