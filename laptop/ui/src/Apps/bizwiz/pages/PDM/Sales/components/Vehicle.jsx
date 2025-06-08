import React, { useState } from 'react';
import { ListItem, ListItemText, Grid, ListItemSecondaryAction, IconButton } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { CurrencyFormat } from '../../../../../../util/Parser';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import TestDrive from "../TestDrive";
import Stock from "../Stock";	

import Nui from '../../../../../../util/Nui';

import Moment from 'react-moment';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		padding: '20px 10px 20px 20px',
		borderBottom: `1px solid ${theme.palette.border.divider}`,
		'&:first-of-type': {
			borderTop: `1px solid ${theme.palette.border.divider}`,
		},
	},
}));

import { vehicleCategories } from '../data';

export default ({ vehicle, dealerData, onClick }) => {
	const classes = useStyles();
	const [testDrive, setTestDrive] = useState(false);
	const [stock, setStock] = useState(false);

	const onInternalClick = () => {
		onClick();
	};

	const onSecondary = (e) => {
		e.stopPropagation();
		setTestDrive(true);
	};

	const onStock = (e) => {
		e.stopPropagation();
		setStock(true);
	};

	const priceMult = 1 + (dealerData?.profitPercentage / 100);
	const salePrice = vehicle?.data?.price * priceMult;

	const startTestDrive = async (data) => {
		setTestDrive(false);
		try {
			let res = await (
				await Nui.send('DealershipStartTestDrive', {
					...data,
					vehicle: vehicle.vehicle,
					modelType: vehicle.modelType,
				})
			).json();

			if (res && res.success) {
				console.log(res?.message ?? 'Vehicle has been delivered for test drive.');
				setTestDrive(false);
			} else {
				console.log(res?.message ?? 'Error Initiating Sale');
			};
			setTestDrive(false);
		} catch (err) {
			console.log(err);
			console.log('Error Initiating Sale');
			setTestDrive(false);
		}
	}

	const startStock = async (data) => {
		setStock(false); // close modal or update state
	
		try {
			let res = await (
				await Nui.send('DealershipSetStock', {
					...data, // includes quantity
					vehicle: vehicle.vehicle,
					modelType: vehicle.modelType,
					class: vehicle?.data?.class,
					quantity: data.quantity, // use from modal input
					price: vehicle?.data?.price,
					make: vehicle?.data?.make,
					model: vehicle?.data?.model,
					category: vehicle?.data?.category,
				})
			).json();
	
			if (res.success) {
				console.log('Stock set successfully:', res.message);
			} else {
				console.warn('Failed to set stock:', res.message);
			}
		} catch (err) {
			console.error('NUI call failed:', err);
		}
	};

	return (
		<><ListItem className={classes.wrapper} button onClick={onInternalClick}>
			<Grid container spacing={1}>
				<Grid item xs={3}>
					<ListItemText primary={'Vehicle Make/Model'} secondary={`${vehicle?.data?.make} ${vehicle?.data?.model}`} />
				</Grid>
				<Grid item xs={1}>
					<ListItemText
						primary={'Class'}
						secondary={`${vehicle?.data?.class}`}
					/>
				</Grid>
				<Grid item xs={2}>
					<ListItemText
						primary={'Price'}
						secondary={`${CurrencyFormat.format(Math.ceil(salePrice))} (${CurrencyFormat.format(vehicle?.data?.price)})`}
					/>
				</Grid>
				<Grid item xs={2} style={{ position: 'relative' }}>
					<ListItemText
						primary={'Quantity'}
						secondary={
							<span style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-start' }}>
								<span>{vehicle?.quantity}</span>
								<IconButton
									size="small"
									style={{ marginLeft: '4px' }} // Adjust spacing here
									onClick={(e) => {
										e.stopPropagation();
										onStock(e);
									}}
								>
									<FontAwesomeIcon icon={['fas', 'cart-flatbed-boxes']} />
								</IconButton>
							</span>
						}
					/>
				</Grid>
				<Grid item xs={2}>
					<ListItemText
						primary={'Category'}
						secondary={`${vehicleCategories.find(c => c.value == vehicle?.data?.category)?.label ?? 'Unknown'}`}
					/>
				</Grid>
				<Grid item xs={2} style={{ position: 'relative' }}>
					<ListItemText
						primary="Last Purchase"
						secondary={vehicle?.lastPurchase ? <Moment unix date={vehicle?.lastPurchase} fromNow /> : 'Never'}
					/>
					<ListItemSecondaryAction style={{ right: 0, top: '50%', transform: 'translateY(-50%)' }}>
						<IconButton
							size="small"
							onClick={(e) => {
								e.stopPropagation();
								onSecondary(e);
							}}
						>
							<FontAwesomeIcon
								icon={['fas', 'steering-wheel']}
							/>
						</IconButton>
					</ListItemSecondaryAction>
				</Grid>
			</Grid>
		</ListItem>
			<TestDrive
				open={testDrive}
				vehicle={vehicle}
				onClose={() => setTestDrive(false)}
				onSubmit={startTestDrive}
			/>
			<Stock
				open={stock}
				vehicle={vehicle}
				onClose={() => setStock(false)}
				onSubmit={startStock}
			/>
		</>

	);
};
