import React, { useEffect, useState, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import {
	Grid,
	IconButton,
	List,
	ListItem,
	ListItemText,
	ListItemSecondaryAction,
	Tooltip,
	Paper,
	Typography,
	Box,
	Chip,
	Button,
} from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Nui from '../../util/Nui';

import { Loader } from '../../components';
import { useAlert } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	heading: {
		color: '#ffffff',
		fontSize: 20,
		fontWeight: 'bold',
		marginBottom: 15,
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	actionBtn: {
		fontSize: 18,
		color: '#ffffff',
		'&:hover': {
			backgroundColor: 'rgba(255, 255, 255, 0.1)',
		},
		'&.Mui-disabled': {
			color: 'rgba(255, 255, 255, 0.3)',
		},
	},
	requestCard: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 12,
		padding: 20,
		marginBottom: 15,
		boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
		'&:hover': {
			background: 'rgba(255, 255, 255, 0.05)',
		},
	},
	requestHeader: {
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
		marginBottom: 15,
	},
	requestTitle: {
		color: '#ffffff',
		fontSize: 18,
		fontWeight: 'bold',
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	requestInfo: {
		color: 'rgba(255, 255, 255, 0.7)',
		fontSize: 14,
		marginBottom: 10,
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	requestStatus: {
		display: 'inline-flex',
		alignItems: 'center',
		padding: '4px 12px',
		borderRadius: 6,
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		fontSize: 12,
		gap: 6,
	},
	emptyState: {
		textAlign: 'center',
		padding: 30,
	},
	emptyTitle: {
		fontSize: 18,
		fontWeight: 'bold',
		color: 'rgba(255, 255, 255, 0.7)',
		marginBottom: 10,
	},
	emptySubtitle: {
		fontSize: 14,
		color: 'rgba(255, 255, 255, 0.5)',
	},
	actionButton: {
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		padding: '8px 16px',
		borderRadius: 6,
		'&:hover': {
			backgroundColor: 'rgba(255, 255, 255, 0.2)',
		},
		'&.Mui-disabled': {
			backgroundColor: 'rgba(255, 255, 255, 0.05)',
			color: 'rgba(255, 255, 255, 0.3)',
		},
	},
	acceptButton: {
		backgroundColor: 'rgba(76, 175, 80, 0.1)',
		color: '#4CAF50',
		'&:hover': {
			backgroundColor: 'rgba(76, 175, 80, 0.2)',
		},
	},
	denyButton: {
		backgroundColor: 'rgba(244, 67, 54, 0.1)',
		color: '#f44336',
		'&:hover': {
			backgroundColor: 'rgba(244, 67, 54, 0.2)',
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const alert = useAlert();

	const myGroup = useSelector((state) => state.data.data.myGroup);
	const myData = useSelector((state) => state.data.data.player);

	const timer = useRef(null);
	const interval = useRef(null);
	const [loading, setLoading] = useState(false);
	const [requests, setRequests] = useState(Array());

	useEffect(() => {
		onRefresh();

		interval.current = setInterval(() => {
			onRefresh();
		}, 30000);

		return () => {
			if (timer?.current) clearTimeout(timer.current);
			if (interval?.current) clearInterval(interval.current);
		}
	}, []);

	const onRefresh = async () => {
		try {
			setLoading(true);
			let res = await (await Nui.send('GetTeamRequests')).json();
			setRequests(res);
		} catch (err) {
			setRequests([
				{
					ID: 1,
					TeamID: 1,
					TeamName: 'Test Team',
					Requester: {
						SID: 1,
						First: 'Testy',
						Last: 'McTest',
					},
					State: 0,
				},
			]);
			console.log(err);
		}
		setLoading(false);
	};

	const onAccept = async (request) => {
		try {
			setLoading(true);
			let res = await (await Nui.send('AcceptTeamRequest', request)).json();

			if (res) {
				alert('Request Accepted');
				onRefresh();
			} else {
				alert('Failed to Accept Request');
			}
		} catch (err) {
			console.log(err);
		}
		setLoading(false);
	};

	const onDeny = async (request) => {
		try {
			setLoading(true);
			let res = await (await Nui.send('DenyTeamRequest', request)).json();

			if (res) {
				alert('Request Denied');
				onRefresh();
			} else {
				alert('Failed to Deny Request');
			}
		} catch (err) {
			console.log(err);
		}
		setLoading(false);
	};

	return (
		<>
			<Typography className={classes.heading}>Team Requests</Typography>
			{!loading ? (
				Boolean(requests) && requests.length > 0 ? (
					requests.map((request) => (
						<Paper key={`request-${request.ID}`} className={classes.requestCard} elevation={0}>
							<Box display="flex" justifyContent="space-between" alignItems="flex-start">
								<Box>
									<Typography className={classes.requestTitle}>
										{request.Requester.First} {request.Requester.Last}
									</Typography>
									<Typography className={classes.requestInfo}>
										Requesting to join: {request.TeamName}
									</Typography>
									<Chip
										label={request.StateName}
										className={classes.requestStatus}
										size="small"
									/>
								</Box>
								{myGroup?.Leader?.SID == myData?.SID && request.State == 0 && (
									<Box>
										<Tooltip title="Accept Request">
											<IconButton
												className={classes.acceptButton}
												onClick={() => onAccept(request)}
											>
												<FontAwesomeIcon icon={['fas', 'check']} />
											</IconButton>
										</Tooltip>
										<Tooltip title="Deny Request">
											<IconButton
												className={classes.denyButton}
												onClick={() => onDeny(request)}
											>
												<FontAwesomeIcon icon={['fas', 'times']} />
											</IconButton>
										</Tooltip>
									</Box>
								)}
							</Box>
						</Paper>
					))
				) : (
					<Box className={classes.emptyState}>
						<Typography variant="h6">No Pending Requests</Typography>
						<Typography variant="body2" style={{ marginTop: 10 }}>
							Team requests will appear here
						</Typography>
					</Box>
				)
			) : (
				<Loader text="Loading" />
			)}
		</>
	);
};
