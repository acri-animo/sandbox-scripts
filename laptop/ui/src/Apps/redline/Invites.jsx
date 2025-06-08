import React, { Fragment } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
	IconButton,
	List,
	ListItem,
	ListItemText,
	Typography,
	Box,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useAlert = () => (message) => console.log(message);

const useStyles = makeStyles((theme) => ({
	content: {
		height: '100%',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		overflowY: 'auto',
		overflowX: 'hidden',
		background: '#16213e',
		'&::-webkit-scrollbar': {
			width: 6,
		},
		'&::-webkit-scrollbar-thumb': {
			background: 'rgba(134, 133, 239, 0.4)',
			borderRadius: '3px',
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: '#8685EF',
		},
		'&::-webkit-scrollbar-track': {
			background: 'transparent',
		},
	},
	header: {
		width: '100%',
		padding: '20px',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		fontSize: 24,
		fontWeight: '600',
		color: 'white',
		borderBottom: '2px solid rgba(134, 133, 239, 0.3)',
		background: 'rgba(134, 133, 239, 0.1)',
		'& span': {
			color: '#8685EF',
			fontWeight: 'bold',
		},
	},
	invite: {
		width: '90%',
		margin: '16px auto',
		padding: '16px',
		borderRadius: '12px',
		background: 'rgba(134, 133, 239, 0.15)',
		border: '1px solid rgba(134, 133, 239, 0.2)',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
		transition: 'all 0.2s ease',
		'&:hover': {
			background: 'rgba(134, 133, 239, 0.2)',
			transform: 'translateY(-2px)',
			boxShadow: '0 4px 12px rgba(134, 133, 239, 0.2)',
		},
		'& span': {
			color: 'white',
			fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
			fontSize: '16px',
			fontWeight: '500',
		},
	},
	race: {
		display: 'flex',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		flex: 1,
	},
	noRaces: {
		width: '100%',
		textAlign: 'center',
		fontSize: 18,
		fontWeight: '500',
		marginTop: '25%',
		color: 'rgba(255, 255, 255, 0.7)',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
	},
	buttonContainer: {
		display: 'flex',
		alignItems: 'center',
		gap: '8px',
	},
	actionButton: {
		width: '40px',
		height: '40px',
		borderRadius: '8px',
		transition: 'all 0.2s ease',
		'&:focus': {
			outline: 'none',
			boxShadow: 'none',
		},
		'&.decline': {
			color: '#ff6b6b',
			backgroundColor: 'rgba(255, 107, 107, 0.1)',
			'&:hover': {
				backgroundColor: 'rgba(255, 107, 107, 0.2)',
				transform: 'scale(1.05)',
			},
		},
		'&.accept': {
			color: '#51cf66',
			backgroundColor: 'rgba(81, 207, 102, 0.1)',
			'&:hover': {
				backgroundColor: 'rgba(81, 207, 102, 0.2)',
				transform: 'scale(1.05)',
			},
		},
	},
}));

export default ({ onViewRace }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const showAlert = useAlert();
	const onDuty = useSelector((state) => state.data.data.onDuty);
	const alias = useSelector(
		(state) => state.data.data.player?.Profiles?.redline,
	);
	const races = useSelector((state) => state.race.races);
	const invites = useSelector((state) => state.race.invites);

	const onAccept = async (id) => {
		try {
			const res = await (await Nui.send('AcceptInvite', id)).json();
			if (res) {
				dispatch({
					type: 'REMOVE_INVITE',
					payload: { id },
				});
				dispatch({
					type: 'I_RACE',
					payload: { state: true },
				});
				showAlert('Event Invite Accepted');
				if (onViewRace) onViewRace(id);
			} else {
				showAlert('Unable To Accept Event Invite');
			}
		} catch (err) {
			console.error(err);
			showAlert('Error Accepting Event Invite');
		}
	};

	const onDecline = async (id) => {
		try {
			const res = await (await Nui.send('DeclineInvite', id)).json();
			if (res) {
				dispatch({
					type: 'REMOVE_INVITE',
					payload: { id },
				});
				showAlert('Event Invite Declined');
			} else {
				showAlert('Unable To Decline Event Invite');
			}
		} catch (err) {
			console.error(err);
			showAlert('Error Declining Event Invite');
		}
	};

	const validInvites = invites.filter((invite) => Boolean(races[invite.id]));

	return (
		<Fragment>
			{Boolean(alias) && onDuty !== 'police' ? (
				<div className={classes.content}>
					<div className={classes.header}>INVITES</div>
					{validInvites.length > 0 ? (
						<List>
							{validInvites.map((invite) => {
								const raceData = races[invite.id];
								return (
									<ListItem
										key={invite.id}
										className={classes.invite}
									>
										<ListItemText
											primary={raceData.name}
											className={classes.race}
										/>
										<Box
											className={classes.buttonContainer}
										>
											<IconButton
												className={`${classes.actionButton} decline`}
												onClick={() =>
													onDecline(invite.id)
												}
												aria-label="Decline invite"
											>
												<FontAwesomeIcon
													icon={['fas', 'x']}
												/>
											</IconButton>
											<IconButton
												className={`${classes.actionButton} accept`}
												onClick={() =>
													onAccept(invite.id)
												}
												aria-label="Accept invite"
											>
												<FontAwesomeIcon
													icon={['fas', 'check']}
												/>
											</IconButton>
										</Box>
									</ListItem>
								);
							})}
						</List>
					) : (
						<Typography className={classes.noRaces}>
							No Pending Event Invites
						</Typography>
					)}
				</div>
			) : (
				<Typography className={classes.noRaces}>
					{alias ? 'Unauthorized: On Duty' : 'Please Set Up Profile'}
				</Typography>
			)}
		</Fragment>
	);
};
