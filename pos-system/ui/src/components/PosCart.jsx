import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTrash } from "@fortawesome/pro-solid-svg-icons";

const PosCart = ({
  cart,
  discount,
  setDiscount,
  updateQuantity,
  removeFromCart,
  total, // Note: total prop is unused in this version but kept for compatibility
  readOnly = false,
}) => {
  // Calculate subtotal for display
  const subtotal = (cart || [])
    .reduce((sum, item) => sum + item.price * (item.quantity || 1), 0)
    .toFixed(2);

  // Treat discount as a flat dollar amount
  const discountAmount = (parseFloat(discount) || 0).toFixed(2);

  // Calculate final total as subtotal - discountAmount, ensuring non-negative
  const finalTotal = Math.max(
    0,
    parseFloat(subtotal) - parseFloat(discountAmount)
  ).toFixed(2);

  return (
    <div className="cart-container">
      <h2 className="cart-header">Cart</h2>
      {(cart || []).length === 0 ? (
        <p style={{ fontFamily: "Oswald" }}>No items in cart</p>
      ) : (
        <div className="cart-content">
          <div className="cart-items">
            {cart.map((item) => (
              <div key={item.item} className="cart-itemcontainer">
                {item.picture && (
                  <img
                    src={item.picture}
                    alt={item.label}
                    className="cart-itemimage"
                  />
                )}
                <div className="cart-itemdetails">
                  <p className="cart-itemlabel">
                    {item.label} x{item.quantity}
                  </p>
                </div>
                {!readOnly && (
                  <div className="cart-notreadonly">
                    <button
                      onClick={() =>
                        updateQuantity(item, (item.quantity || 1) - 1)
                      }
                      className="cart-quantitybuttons"
                    >
                      -
                    </button>
                    <button
                      onClick={() =>
                        updateQuantity(item, (item.quantity || 1) + 1)
                      }
                      className="cart-quantitybuttons"
                    >
                      +
                    </button>
                    <button
                      onClick={() => removeFromCart(item)}
                      className="cart-quantityremove"
                    >
                      <FontAwesomeIcon icon={faTrash} />
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
          <div className="cart-footer">
            <div className="cart-pricedetails">
              <p>Subtotal: ${subtotal}</p>
              <p>Discount: ${discountAmount}</p>
              {!readOnly && (
                <>
                  <label className="cart-discountlabel">Discount ($):</label>
                  <input
                    type="number"
                    value={discount}
                    onChange={(e) =>
                      setDiscount(parseFloat(e.target.value) || 0)
                    }
                    className="cart-discountinput"
                    min="0"
                    max={subtotal} // Prevent discount exceeding subtotal
                    step="0.01" // Allow decimal places for dollar amounts
                  />
                </>
              )}
            </div>
            <div className="cart-totalprice">
              <p className="font-semibold">Total: ${finalTotal}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PosCart;
