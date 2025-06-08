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
	teamCard: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 12,
		padding: 20,
		marginBottom: 15,
		boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
		'&:hover': {
			background: 'rgba(255, 255, 255, 0.05)',
		},
	},
	teamName: {
		color: '#ffffff',
		fontSize: 18,
		fontWeight: 'bold',
		marginBottom: 10,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
	},
	teamInfo: {
		color: 'rgba(255, 255, 255, 0.7)',
		fontSize: 14,
		marginBottom: 5,
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	teamStatus: {
		display: 'inline-flex',
		alignItems: 'center',
		padding: '4px 12px',
		borderRadius: 6,
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		fontSize: 12,
		marginBottom: 15,
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
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const alert = useAlert();

	const myGroup = useSelector((state) => state.data.data.myGroup);

	const timer = useRef(null);
	const interval = useRef(null);
	const [loading, setLoading] = useState(false);
	const [teams, setTeams] = useState(Array());
	const [cooldown, setCooldown] = useState(false);

	useEffect(() => {
		onRefresh();

		interval.current = setInterval(() => {
			onRefresh();
		}, 120000);

		return () => {
			if (timer?.current) clearTimeout(timer.current);
			if (interval?.current) clearInterval(interval.current);
		}
	}, []);

	const onRefresh = async () => {
		try {
			setLoading(true);
			let res = await (await Nui.send('GetTeams')).json();
			setTeams(res);
		} catch (err) {
			setTeams([
				{
					Name: 'Dick',
					ID: 1,
					Members: Array(
						{
							Leader: true,
							SID: 1,
							First: 'Testy',
							Last: 'McTest',
						},
					),
					State: 0,
				},
			]);
			console.log(err);
		}
		setLoading(false);
	};

	const onRequestInvite = async (team) => {
		try {
			setLoading(true);
			setCooldown(true);
			let res = await (await Nui.send('RequestTeamInvite', team)).json();

			if (res) {
				alert('Invite Requested');
			} else {
				alert('Invite Request Failed');
			}
		} catch (err) {
			console.log(err);
		}

		timer.current = setTimeout(() => setCooldown(false), 20000);
		setLoading(false);
	};

	return (
		<>
			<Typography className={classes.heading}>Active Teams</Typography>
			{!loading ? (
				Boolean(teams) && teams.length > 0 ? (
					teams.map((team) => (
						<Paper key={`actv-team-${team.ID}`} className={classes.teamCard} elevation={0}>
							<Box display="flex" justifyContent="space-between" alignItems="flex-start">
								<Box>
									<Typography className={classes.teamName}>{team.Name}</Typography>
									<Typography className={classes.teamInfo}>
										{team.Members.length}/5 Members
									</Typography>
									<Chip
										label={team.StateName}
										className={classes.teamStatus}
										size="small"
									/>
								</Box>
								{!Boolean(myGroup) && (
									<Tooltip title="Request To Join">
										<IconButton
											className={classes.actionBtn}
											onClick={() => onRequestInvite(team.ID)}
											disabled={cooldown || team.Members?.length >= 5}
										>
											<FontAwesomeIcon icon={['fas', 'user-plus']} />
										</IconButton>
									</Tooltip>
								)}
							</Box>
						</Paper>
					))
				) : (
					<Box className={classes.emptyState}>
						<Typography variant="h6">No Available Teams</Typography>
						<Typography variant="body2" style={{ marginTop: 10 }}>
							Create a team or wait for others to create one
						</Typography>
					</Box>
				)
			) : (
				<Loader text="Loading" />
			)}
		</>
	);
};
