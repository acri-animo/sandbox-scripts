import React from 'react';
import { Box, Typography, Button } from '@mui/material';
import { CurrencyFormat } from '../../../../../util/Parser';

const StockSuccessPage = ({ vehicle, quantity, totalCost, onClose }) => {
  return (
    <Box
      display="flex"
      flexDirection="column"
      justifyContent="center"
      alignItems="center"
      padding={2}
      height="100vh"
      bgcolor="#f4f6f8"
    >
      <Typography variant="h4" color="primary" gutterBottom>
        Stock Added Successfully!
      </Typography>
      <Typography variant="h6" color="textSecondary">
        Vehicle: {`${vehicle?.data?.make} ${vehicle?.data?.model}`}
      </Typography>
      <Typography variant="subtitle1" color="textSecondary" gutterBottom>
        Quantity Added: {quantity}
      </Typography>
      <Typography variant="subtitle1" fontWeight="bold">
        Total Cost: {CurrencyFormat.format(totalCost)}
      </Typography>

      <Box mt={2}>
        <Button variant="contained" color="primary" onClick={onClose}>
          Close
        </Button>
      </Box>
    </Box>
  );
};

export default StockSuccessPage;
