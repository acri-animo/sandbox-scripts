import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import {
	Grid,
	TextField,
	ButtonGroup,
	Button,
	Backdrop,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import Nui from '../../../../util/Nui';
import { Loader } from '../../../../components';
import { useAlert } from '../../../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		padding: '20px 10px 20px 20px',
		height: '95%',
	},
	editorField: {
		marginBottom: 10,
	},
	title: {
		fontSize: 22,
		color: theme.palette.text.main,
		textAlign: 'center',
	},
	col: {
		height: '100%',
		padding: 5,
	},
	formActions: {
		paddingBottom: 10,
		marginBottom: 5,
		borderBottom: `1px inset ${theme.palette.border.divider}`,
	},
	positiveButton: {
		borderColor: `${theme.palette.success.main}80`,
		color: theme.palette.success.main,
		'&:hover': {
			borderColor: theme.palette.success.main,
			background: `${theme.palette.success.main}14`,
		},
	},
	tableContainer: {
		marginTop: '-30vh',
		maxHeight: '50vh',
		overflowY: 'auto',
	},
}));

export default ({ onNav }) => {
	const classes = useStyles();
	const alert = useAlert();
	const onDuty = useSelector((state) => state.data.data.onDuty);

	const initialState = {
		itemName: '',
		picture: '',
		price: '',
	};

	const [loading, setLoading] = useState(false);
	const [state, setState] = useState(initialState);
	const [items, setItems] = useState([]);
	const [editingPrice, setEditingPrice] = useState({});

	// Fetch all items for the current job
	useEffect(() => {
		const fetchItems = async () => {
			setLoading(true);
			try {
				let res = await (
					await Nui.send('PosItemsFetchEdit', { job: onDuty })
				).json();
				if (res && res.status && Array.isArray(res.items)) {
					setItems(res.items);
				} else {
					alert('Unable to Fetch Items');
				}
			} catch (err) {
				console.error(err);
				alert('Error Fetching Items');
			}
			setLoading(false);
		};

		if (onDuty) fetchItems();
	}, [onDuty]);

	const onSubmit = async (e) => {
		e.preventDefault();

		if (state.itemName === '') {
			alert('Must Add Item Name');
			return;
		}
		if (state.picture === '') {
			alert('Must Add Picture URL');
			return;
		}
		if (state.price === '' || isNaN(state.price) || state.price <= 0) {
			alert('Must Add Valid Price');
			return;
		}

		setLoading(true);
		try {
			const itemData = {
				item: state.itemName,
				picture: state.picture,
				price: parseFloat(state.price),
				category: 'Specials',
			};

			let res = await (
				await Nui.send('PosItemCreate', {
					job: onDuty,
					doc: itemData,
				})
			).json();

			if (res && res.status) {
				alert('Special Item Created Successfully');
				setState(initialState);
				// Refresh items list
				let updatedItems = await (
					await Nui.send('PosItemsFetchEdit', { job: onDuty })
				).json();
				if (updatedItems && updatedItems.status)
					setItems(updatedItems.items);
			} else {
				alert(res.message || 'Unable to Create Special Item');
			}
		} catch (err) {
			console.error(err);
			alert('Error Creating Special Item');
		}
		setLoading(false);
	};

	const onPriceChange = (itemName, value) => {
		setEditingPrice({ ...editingPrice, [itemName]: value });
	};

	const onPriceSubmit = async (item) => {
		if (
			!editingPrice[item.label] ||
			isNaN(editingPrice[item.label]) ||
			editingPrice[item.label] <= 0
		) {
			alert('Please enter a valid price');
			return;
		}

		setLoading(true);
		try {
			let res = await (
				await Nui.send('PosItemUpdatePrice', {
					job: onDuty,
					itemName: item.item,
					price: parseFloat(editingPrice[item.label]),
				})
			).json();

			if (res) {
				alert('Price Updated Successfully');
				// Update local items state
				setItems(
					items.map((i) =>
						i.label === item.label
							? {
									...i,
									price: parseFloat(editingPrice[item.label]),
							  }
							: i,
					),
				);
				setEditingPrice({ ...editingPrice, [item.label]: undefined });
			} else {
				alert('Unable to Update Price');
			}
		} catch (err) {
			console.error(err);
			alert('Error Updating Price');
		}
		setLoading(false);
	};

	return (
		<div className={classes.wrapper}>
			<Backdrop open={loading} style={{ zIndex: 100 }}>
				<Loader text="Processing..." />
			</Backdrop>
			<Grid container style={{ height: '100%' }} spacing={2}>
				<Grid item xs={12}>
					<Grid container className={classes.formActions}>
						<Grid item xs={10}>
							<div className={classes.title}>
								New Special Item
							</div>
						</Grid>
						<Grid item xs={2} style={{ textAlign: 'right' }}>
							<ButtonGroup fullWidth color="inherit">
								<Button
									className={classes.positiveButton}
									onClick={onSubmit}
								>
									Create Special
								</Button>
							</ButtonGroup>
						</Grid>
					</Grid>
				</Grid>
				<Grid item xs={6} className={classes.col}>
					<TextField
						className={classes.editorField}
						label="Item Name"
						fullWidth
						placeholder="e.g., Tiramisu"
						value={state.itemName}
						onChange={(e) =>
							setState({ ...state, itemName: e.target.value })
						}
					/>
					<TextField
						className={classes.editorField}
						label="Picture URL"
						fullWidth
						placeholder="e.g., https://placehold.co/100x100?text=Item"
						value={state.picture}
						onChange={(e) =>
							setState({ ...state, picture: e.target.value })
						}
					/>
					<TextField
						className={classes.editorField}
						label="Price"
						fullWidth
						type="number"
						placeholder="e.g., 12"
						value={state.price}
						onChange={(e) =>
							setState({ ...state, price: e.target.value })
						}
					/>
				</Grid>
				<Grid item xs={6} className={classes.col}>
					{state.picture && (
						<img
							src={state.picture}
							alt="Preview"
							style={{ maxWidth: '100px', maxHeight: '100px' }}
							onError={(e) =>
								(e.target.src =
									'https://placehold.co/100x100?text=Error')
							}
						/>
					)}
				</Grid>
				<Grid item xs={12}>
					<TableContainer
						component={Paper}
						className={classes.tableContainer}
					>
						<Table stickyHeader>
							<TableHead>
								<TableRow>
									<TableCell>Item Name</TableCell>
									<TableCell>Category</TableCell>
									<TableCell>Price</TableCell>
									<TableCell>Actions</TableCell>
								</TableRow>
							</TableHead>
							<TableBody>
								{items.map((item) => (
									<TableRow key={item.label}>
										<TableCell>{item.label}</TableCell>
										<TableCell>{item.category}</TableCell>
										<TableCell>
											<TextField
												type="number"
												value={
													editingPrice[item.label] ??
													item.price
												}
												onChange={(e) =>
													onPriceChange(
														item.label,
														e.target.value,
													)
												}
												size="small"
											/>
										</TableCell>
										<TableCell>
											<Button
												className={
													classes.positiveButton
												}
												onClick={() =>
													onPriceSubmit(item)
												}
												disabled={
													!editingPrice[item.label] ||
													editingPrice[item.label] ===
														item.price
												}
											>
												Update Price
											</Button>
										</TableCell>
									</TableRow>
								))}
							</TableBody>
						</Table>
					</TableContainer>
				</Grid>
			</Grid>
		</div>
	);
};
