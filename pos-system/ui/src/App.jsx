import { useState, useEffect } from "react";
import PosItem from "./components/PosItem";
import PosCart from "./components/PosCart";
import PosCheckout from "./components/PosCheckout";
import CustomerPosView from "./components/CustomerPosView";
import nuiCallback from "./utils/nuicallback";
import "./App.css";

const mockItems = {
  al_dente: [
    {
      item: "margherita_pizza",
      label: "Margherita Pizza",
      picture: "https://placehold.co/100x100?text=Pizza",
      price: 12.99,
      category: "Food",
    },
    {
      item: "spaghetti_carbonara",
      label: "Spaghetti Carbonara",
      picture: "https://placehold.co/100x100?text=Pasta",
      price: 10.5,
      category: "Food",
    },
    {
      item: "tiramisu",
      label: "Tiramisu",
      picture:
        "https://cdn.discordapp.com/attachments/1257138808005328976/1370832530562879548/tiramisu-on-plate.png?ex=6820eec8&is=681f9d48&hm=0de272489a8cbb30c3d9fa3d41be665e83bb5bd3cbbe615071b6094378d0c970&",
      price: 6.0,
      category: "Specials",
    },
    {
      item: "house_salad",
      label: "House Salad",
      picture: "https://placehold.co/100x100?text=Salad",
      price: 7.25,
      category: "Food",
    },
    {
      item: "cola",
      label: "Cola",
      picture: "https://placehold.co/100x100?text=Cola",
      price: 2.5,
      category: "Drinks",
    },
  ],
};

// Mock orders for single-order system (cart can have multiple items)
const mockOrders = {
  al_dente: [
    {
      orderId: "pending",
      data: {
        cart: [
          {
            item: "margherita_pizza",
            label: "Margherita Pizza",
            price: 12.99,
            quantity: 1,
          },
          { item: "cola", label: "Cola", price: 2.5, quantity: 2 },
        ],
        discount: 0,
        total: 17.99, // 12.99 + (2.5 * 2)
        employeeName: "John Doe",
        timestamp: Math.floor(Date.now() / 1000),
      },
    },
  ],
};

function App() {
  const [isPosOpen, setIsPosOpen] = useState(false);
  const [posData, setPosData] = useState(null);
  const [posType, setPosType] = useState(null);
  const [items, setItems] = useState([]);
  const [orders, setOrders] = useState([]);
  const [employee, setEmployee] = useState(null);
  const [cart, setCart] = useState([]);
  const [discount, setDiscount] = useState(0);
  const [activeTab, setActiveTab] = useState("Food");
  const [checkoutReady, setCheckoutReady] = useState(false);
  const [loading, setLoading] = useState(false);

  const useMockData = false;

  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data.action === "openPosSystem") {
        setPosData(event.data.data);
        setPosType(event.data.data.posType);
        if (event.data.data.posType === "employee") {
          setEmployee(event.data.data.employee);
          fetchItems(event.data.data.job);
        } else if (event.data.data.posType === "customer") {
          fetchOrder(event.data.data.job);
        }
        setIsPosOpen(true);
      } else if (event.data.action === "updateOrders") {
        if (event.data.data.job === posData?.job && posType === "customer") {
          // No sorting needed for single order
          setOrders(event.data.data.orders || []);
        }
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [posData, posType]);

  const fetchOrder = async (job) => {
    setLoading(true);
    try {
      if (useMockData) {
        ordersToSet = mockOrders[job] || [];
      } else {
        const data = await nuiCallback("fetchPOSOrder", { job });
        if (data.status) {
          setOrders(data.orders);
        }
      }
    } catch (error) {
      console.error("Error fetching orders:", error);
    }
    setLoading(false);
  };

  const fetchItems = async (job) => {
    setLoading(true);
    try {
      let itemsToSet = [];
      if (useMockData) {
        itemsToSet = mockItems[job] || [];
      } else {
        const data = await nuiCallback("fetchPOSItems", { job });
        if (data.status) {
          itemsToSet = data.items.map((item) => ({
            item: item.item,
            label: item.label || item.item,
            price: item.price,
            category: item.category,
            picture: item.picture,
          }));
        }
      }
      itemsToSet.sort((a, b) => a.label.localeCompare(b.label));
      setItems(itemsToSet);
    } catch (error) {
      console.error("Error fetching items:", error);
    }
    setLoading(false);
  };

  const addToCart = (item) => {
    const existingItem = cart.find((cartItem) => cartItem.item === item.item);
    if (existingItem) {
      const updatedCart = cart.map((cartItem) =>
        cartItem.item === item.item
          ? { ...cartItem, quantity: (cartItem.quantity || 1) + 1 }
          : cartItem
      );
      setCart(updatedCart);
    } else {
      setCart([...cart, { ...item, quantity: 1 }]);
    }
  };

  const updateQuantity = (item, quantity) => {
    if (quantity <= 0) {
      removeFromCart(item);
      return;
    }
    const updatedCart = cart.map((cartItem) =>
      cartItem.item === item.item ? { ...cartItem, quantity } : cartItem
    );
    setCart(updatedCart);
  };

  const removeFromCart = (item) => {
    const updatedCart = cart.filter((cartItem) => cartItem.item !== item.item);
    setCart(updatedCart);
  };

  const calculateTotal = () => {
    const subtotal = cart.reduce((total, item) => {
      return total + item.price * (item.quantity || 1);
    }, 0);
    const total = subtotal - discount;
    return total < 0 ? 0 : Math.round(total);
  };

  const handleCheckout = async (paymentMethod, order) => {
    if (useMockData) {
      console.log("Checkout with mock data:", order.data, paymentMethod);
      setOrders([]); // Clear orders after checkout
      return;
    }
    try {
      const data = await nuiCallback("posCheckout", {
        cart: order.cart,
        discount: order.discount,
        total: order.total,
        job: order.job,
        employeeName: order.employeeName,
        paymentMethod: paymentMethod || "unknown",
        timestamp: order.timestamp,
      });
      if (data.money === "rich") {
        setOrders([]);
        handleClose();
      } else {
        console.error("Checkout failed:", data.message);
      }
    } catch (error) {
      console.error("Checkout error:", error);
    }
  };

  const handleSetCheckout = async () => {
    if (cart.length === 0) {
      console.error("Cart is empty.");
      return;
    }
    try {
      const orderSet = await nuiCallback("posSetCart", {
        cart,
        discount,
        total: calculateTotal(),
        job: posData.job,
        employeeName: employee.name || "Unknown Employee",
      });
      if (orderSet.status) {
        setCheckoutReady(true);
      }
    } catch (error) {
      console.error("Error setting checkout:", error);
    }
  };

  const handleClearCheckout = async () => {
    try {
      const clearCart = await nuiCallback("clearPosCheckout", {
        job: posData.job,
      });
      if (clearCart.status) {
        setCart([]);
        setDiscount(0);
        setCheckoutReady(false);
      }
    } catch (error) {
      console.error("Error clearing checkout:", error);
    }
  };

  const handleClose = async () => {
    if (useMockData) {
      setIsPosOpen(false);
      return;
    }
    try {
      const data = await nuiCallback("closePosSystem", {});
      if (data.status) {
        setIsPosOpen(false);
        setOrders([]);
      }
    } catch (error) {
      console.error("Error closing POS system:", error);
    }
  };

  useEffect(() => {
    const handleKeyPress = (event) => {
      if (event.key === "Escape" && isPosOpen) {
        handleClose();
      }
    };
    window.addEventListener("keydown", handleKeyPress);
    return () => window.removeEventListener("keydown", handleKeyPress);
  }, [isPosOpen]);

  if (!isPosOpen || !posData) return null;

  return (
    <div
      className={`root-container ${
        posType === "employee" ? "employee-view" : "customer-view"
      }`}
    >
      {isPosOpen ? (
        <div className="main-container">
          <div className="pos-header">
            <h1 className="pos-title">
              POS System{" "}
              <span
                style={{
                  color: "#8685ef",
                  fontSize: "2.2vh",
                  marginLeft: "0.5vw",
                }}
              >
                {posData?.jobName}
              </span>
            </h1>
            {posType === "employee" && (
              <div className="user-info">
                <span style={{ color: "white" }}>Welcome</span>
                <span style={{ marginLeft: "0.5vw" }}>
                  {employee?.name} - {employee?.grade}
                </span>
              </div>
            )}
          </div>

          {loading ? (
            <p>Loading...</p>
          ) : posType === "employee" ? (
            <>
              <div className="pos-tabs">
                {["Food", "Drinks", "Specials"].map((tab) => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className="pos-tabsingle"
                  >
                    {tab}
                  </button>
                ))}
              </div>
              <div className="pos-grid">
                <div className="pos-gridspan">
                  <div className="pos-gridcols">
                    {items.length > 0 ? (
                      items
                        .filter((item) => item.category === activeTab)
                        .map((item) => (
                          <PosItem
                            key={item.item}
                            item={item}
                            onAdd={() => addToCart(item)}
                          />
                        ))
                    ) : (
                      <p>No items available</p>
                    )}
                  </div>
                </div>
                <div className="col-span-1">
                  <PosCart
                    cart={cart}
                    discount={discount}
                    setDiscount={setDiscount}
                    updateQuantity={updateQuantity}
                    removeFromCart={removeFromCart}
                    total={calculateTotal()}
                  />
                  <PosCheckout
                    onCheckout={handleCheckout}
                    onSetCheckout={handleSetCheckout}
                    onClearCheckout={handleClearCheckout}
                    cart={cart}
                  />
                </div>
              </div>
            </>
          ) : (
            <CustomerPosView
              orders={orders}
              onCheckout={handleCheckout}
              checkoutReady={checkoutReady}
              job={posData.job}
            />
          )}
        </div>
      ) : (
        <div className="flex items-center justify-center h-screen">
          <p className="text-lg">Waiting for POS to open...</p>
        </div>
      )}
    </div>
  );
}

export default App;
