import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/pro-solid-svg-icons";

function PosItem({ item, onAdd }) {
  return (
    <div className="item-container">
      <img src={item.picture} alt={item.label} className="item-image" />
      <h3 className="item-label">{item.label}</h3>
      <p className="item-price">${item.price.toFixed(2)}</p>
      <button onClick={onAdd} className="item-button">
        <FontAwesomeIcon icon={faPlus} className="item-addicon" /> Add to Cart
      </button>
    </div>
  );
}

export default PosItem;
