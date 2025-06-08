import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles, withStyles } from '@mui/styles';
import { Grid, Paper, Typography, Box, Divider } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { throttle } from 'lodash';

import Window from '../../components/Window';
import MyTeam from '../teams/MyTeam';
import Available from './Available';
import Requests from './Requests';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		background: 'linear-gradient(135deg, #0a0a0f 0%, #0f0f1a 50%, #14141f 100%)',
		padding: 20,
		overflow: 'auto',
	},
	header: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 12,
		padding: '20px 25px',
		marginBottom: 20,
		boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
	},
	headerTitle: {
		color: '#ffffff',
		fontSize: 28,
		fontWeight: 'bold',
		display: 'flex',
		alignItems: 'center',
		gap: 12,
	},
	headerIcon: {
		color: 'rgba(255, 255, 255, 0.7)',
		fontSize: 24,
	},
	content: {
		height: 'calc(100% - 120px)',
		overflow: 'hidden',
	},
	section: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 12,
		padding: 20,
		height: '100%',
		overflow: 'auto',
		boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
		'&::-webkit-scrollbar': {
			width: 6,
		},
		'&::-webkit-scrollbar-thumb': {
			background: 'rgba(255, 255, 255, 0.2)',
			borderRadius: 3,
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: 'rgba(255, 255, 255, 0.3)',
		},
		'&::-webkit-scrollbar-track': {
			background: 'transparent',
		},
	},
	sectionHeader: {
		marginBottom: 15,
		paddingBottom: 10,
		borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
	},
	sectionTitle: {
		color: '#ffffff',
		fontSize: 18,
		fontWeight: 'bold',
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	emptyMsg: {
		width: '100%',
		textAlign: 'center',
		padding: 30,
		color: 'rgba(255, 255, 255, 0.7)',
	},
	emptyTitle: {
		fontSize: 20,
		fontWeight: 'bold',
		marginBottom: 10,
	},
	emptySubtitle: {
		fontSize: 14,
		color: 'rgba(255, 255, 255, 0.5)',
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();

	return (
		<div className={classes.wrapper}>
			<Paper className={classes.header} elevation={0}>
				<Typography className={classes.headerTitle}>
					<FontAwesomeIcon icon={['fas', 'users']} className={classes.headerIcon} />
					Teams Management
				</Typography>
			</Paper>
			<Grid container spacing={3} className={classes.content}>
				<Grid item xs={12} md={4}>
					<Paper className={classes.section} elevation={0}>
						<Box className={classes.sectionHeader}>
							<Typography className={classes.sectionTitle}>
								<FontAwesomeIcon icon={['fas', 'user-friends']} />
								My Team
							</Typography>
						</Box>
						<MyTeam />
					</Paper>
				</Grid>
				<Grid item xs={12} md={4}>
					<Paper className={classes.section} elevation={0}>
						<Box className={classes.sectionHeader}>
							<Typography className={classes.sectionTitle}>
								<FontAwesomeIcon icon={['fas', 'users']} />
								Available Teams
							</Typography>
						</Box>
						<Available />
					</Paper>
				</Grid>
				<Grid item xs={12} md={4}>
					<Paper className={classes.section} elevation={0}>
						<Box className={classes.sectionHeader}>
							<Typography className={classes.sectionTitle}>
								<FontAwesomeIcon icon={['fas', 'envelope']} />
								Team Requests
							</Typography>
						</Box>
						<Requests />
					</Paper>
				</Grid>
			</Grid>
		</div>
	);
};
