import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles, withStyles } from '@mui/styles';
import { Avatar, Button, Grid, TextField } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Moment from 'react-moment';
import Nui from '../../../util/Nui';
import { useAlert } from '../../../hooks';
import NumberFormat from 'react-number-format';

const useStyles = makeStyles((theme) => ({
	contract: {
		padding: '20px',
		background: 'rgba(30, 30, 30, 0.8)',
		border: '1px solid rgba(255, 255, 255, 0.1)',
		borderRadius: '8px',
		textAlign: 'center',
		transition: 'all 0.3s ease',
		'&:hover': {
			borderColor: 'rgba(255, 255, 255, 0.2)',
			boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
		},
		'&:not(:last-of-type)': {
			marginBottom: '16px',
		},
	},
	contractClass: {
		width: 80,
		height: 80,
		margin: 'auto',
		marginBottom: 15,
		background: 'rgba(255, 255, 255, 0.1)',
		fontSize: '24px',
		fontWeight: '600',
		color: '#FFFFFF',
		border: '2px solid rgba(255, 255, 255, 0.2)',
	},
	vehicleLabel: {
		fontSize: '20px',
		color: '#FFFFFF',
		fontWeight: '600',
		marginBottom: '8px',
	},
	contractOwner: {
		fontSize: '14px',
		color: 'rgba(255, 255, 255, 0.7)',
		marginBottom: '8px',
	},
	contractPrice: {
		fontSize: '16px',
		color: '#4CAF50',
		fontWeight: '600',
		marginBottom: '8px',
		'& small': {
			marginLeft: '8px',
			color: 'rgba(255, 255, 255, 0.7)',
			fontSize: '14px',
			'&::before': {
				content: '"("',
				marginRight: '2px',
			},
			'&::after': {
				content: '")"',
				marginLeft: '2px',
			},
		},
	},
	contractExpiration: {
		fontSize: '13px',
		color: 'rgba(255, 255, 255, 0.6)',
		marginBottom: '16px',
	},
	buttonContainer: {
		marginTop: '16px',
		'& button': {
			marginBottom: '8px',
			borderRadius: '8px',
			textTransform: 'none',
			fontWeight: '600',
			padding: '8px 16px',
			transition: 'all 0.3s ease',
			'&:hover': {
				transform: 'translateY(-2px)',
			},
		},
	},
}));

export default ({ contract, repLevel }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const alert = useAlert();

	const disabledContracts = useSelector(state => state.data.data.disabledBoostingContracts);
	const [accepting, setAccepting] = useState(false);
	const [loading, setLoading] = useState(false);

	const [bid, setBid] = useState(0);

	const acceptContract = async (c, isScratch) => {
		setLoading(true);
		setAccepting(false);

		try {
			const res = await (await Nui.send("Boosting:AcceptContract", {
				...c,
				scratch: isScratch,
			})).json();

			if (res?.success) {
				alert('Request Sent to Team Leader');
			} else {
				if (res?.message) {
					alert(res.message);
				} else {
					alert('Failed to Accept Contract');
				}
			}
		} catch(e) {
			console.log(e);
		}

		setLoading(false);
	};

	const isDisabled = disabledContracts?.includes(contract.id);
	const isDisabledByRep = (repLevel < contract.vehicle.classLevel && !contract.vehicle.rewarded);

	return (
		<Grid item xs={2}>
			<Grid container className={classes.contract}>
				<Grid item xs={12}>
					<Avatar
						className={`${classes.contractClass} ${contract.vehicle.class}`}
					>
						{contract.vehicle.class}
					</Avatar>
				</Grid>
				<Grid item xs={12} className={classes.vehicleLabel}>
					{contract.vehicle.label}
				</Grid>
				<Grid item xs={12} className={classes.contractOwner}>
					{contract.owner.Alias}
				</Grid>
				<Grid item xs={12} className={classes.contractPrice}>
					<span>
						{contract.prices.standard.price}
						{' $'}{contract.prices.standard.coin}
					</span>
					{Boolean(contract.prices.scratch) && (
						<small>
							{contract.prices.scratch.price}
							{' $'}{contract.prices.scratch.coin}
						</small>
					)}
				</Grid>
				<Grid item xs={12} className={classes.contractExpiration}>
					Expires: <Moment fromNow unix date={contract.expires} />
				</Grid>
				{!accepting ? (
						<Grid item xs={12} className={classes.buttonContainer}>
							<Button
								fullWidth
								variant="contained"
								color="success"
								onClick={() => setAccepting(true)}
								disabled={isDisabled || loading || isDisabledByRep}
							>
								Place Your Bid
							</Button>				
							<Button
								fullWidth
								variant="contained"
								color="warning"
								disabled={isDisabled || loading}
							>
								Transfer Contract
							</Button>
							<Button 
								fullWidth 
								variant="contained" 
								color="error"
								disabled={isDisabled || loading}
							>
								Delist Contract
							</Button>
						</Grid>
				) : (
					<>
						<Grid item xs={12} className={classes.buttonContainer}>
							<NumberFormat
								fullWidth
								required
								label={`Your Bid ${contract.prices.standard.coin}`}
								name="bid"
								className={classes.editorField}
								value={bid}
								onChange={(e) => setBid(e.target.value)}
								type="tel"
								isNumericString
								customInput={TextField}
							/>
							 <Button 
								fullWidth 
								variant="contained" 
								color="info"
								onClick={() => acceptContract(contract, false)}
							>
								Standard ({contract.prices.standard.price} $
								{contract.prices.standard.coin})
							</Button> 
						</Grid>
						{Boolean(contract.prices.scratch) && (
							<Grid item xs={12} style={{ marginTop: 15 }}>
								<Button
									fullWidth
									variant="contained"
									color="warning"
									onClick={() => acceptContract(contract, false)}
								>
									VIN Scratch ({contract.prices.scratch.price}{' '}
									${contract.prices.scratch.coin})
								</Button>
							</Grid>
						)}
						<Grid item xs={12} style={{ marginTop: 15 }}>
							<Button
								fullWidth
								variant="contained"
								color="error"
								onClick={() => setAccepting(false)}
							>
								Cancel
							</Button>
						</Grid>
					</>
				)}
			</Grid>
		</Grid>
	);
};
