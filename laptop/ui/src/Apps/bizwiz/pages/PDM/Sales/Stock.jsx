import React, { useState } from 'react';
import { makeStyles } from '@mui/styles';
import { Modal } from '../../../../../components';
import { TextField, Typography, Box, Button } from '@mui/material';
import { CurrencyFormat } from '../../../../../util/Parser';
import StockSuccessPage from './StockSuccessPage'; // Import the success page

const useStyles = makeStyles(() => ({
	editorField: {
		marginBottom: 10,
	},
}));

export default ({ open, vehicle, onSubmit, onClose, success, quantityToAdd }) => {
	const classes = useStyles();

	const initialState = {
		type: 'stock',
		quantity: 1,
	};

	const [state, setState] = useState({ ...initialState });

	const internalSubmit = (e) => {
		e.preventDefault();
		onSubmit(state); // Pass quantity to parent
		setState({ ...initialState });
	};

	const handleInputChange = (e) => {
		const { name, value } = e.target;
		const numericValue = Math.max(1, parseInt(value) || 1); // Ensure at least 1
		setState({
			...state,
			[name]: numericValue,
		});
	};

	const cashPrice = vehicle?.data?.price || 0;
	const totalCost = cashPrice * state.quantity;

	// Handle the success page after stock is successfully added
	if (success) {
		return (
			<StockSuccessPage
				vehicle={vehicle}
				quantity={state.quantity}
				totalCost={totalCost}
				onClose={onClose}
			/>
		);
	}

	// The normal modal for stock addition
	return (
		<Modal
			open={open}
			maxWidth="md"
			title={`Add Stock: ${vehicle?.data?.make} ${vehicle?.data?.model}`}
			submitLang="Confirm Stock"
			onSubmit={internalSubmit}
			onClose={onClose}
		>
			<p>Vehicle: {`${vehicle?.data?.make} ${vehicle?.data?.model}`}</p>

			<TextField
				required
				fullWidth
				type="number"
				label="Quantity to Add"
				name="quantity"
				className={classes.editorField}
				value={state.quantity}
				onChange={handleInputChange}
				inputProps={{ min: 1 }}
			/>

			<Box mt={2}>
				<Typography variant="subtitle1" fontWeight="bold">
					Total Cost: {CurrencyFormat.format(totalCost)}
				</Typography>
			</Box>
		</Modal>
	);
};
