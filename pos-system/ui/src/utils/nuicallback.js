// utils/nuiCallback.js

const nuiCallback = async (endpoint, payload) => {
  try {
    const response = await fetch(`https://lumen-pos/${endpoint}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });
    const data = await response.json();
    if (!data.status) {
      console.error(`Failed at ${endpoint}:`, data.message || "Unknown error");
    }
    return data;
  } catch (error) {
    console.error(`Error in ${endpoint}:`, error);
    return { status: false, message: error.message };
  }
};

export default nuiCallback;
