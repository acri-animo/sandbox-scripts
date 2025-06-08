import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Paper, Typography, Box } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Nui from '../../../util/Nui';
import { useAlert } from '../../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		padding: '10px',
		background: '#1E1E1E',
		border: '1px solid #2A2A2A',
		height: '100%',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
	},
	title: {
		fontSize: '14px',
		color: '#FFFFFF',
		fontWeight: '500',
		marginBottom: '8px',
	},
	progressBar: {
		height: '4px',
		background: '#2A2A2A',
		borderRadius: '2px',
		marginBottom: '6px',
		overflow: 'hidden',
	},
	progressFill: {
		height: '100%',
		background: '#4CAF50',
		borderRadius: '2px',
	},
	rankInfo: {
		display: 'flex',
		justifyContent: 'space-between',
		alignItems: 'center',
		fontSize: '12px',
	},
	currentRank: {
		color: '#4CAF50',
	},
	nextRank: {
		color: '#AAAAAA',
	},
}));

export default ({ rep, myGroup, disabled }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const showAlert = useAlert();

	const normalise = (value = 500) => {
		const min = rep?.current?.value ?? 0;
		const max = rep?.next?.value ?? 1000;
		return ((value - min) * 100) / (max - min);
	};

	const progress = normalise(rep.value);

	return (
		<Paper className={classes.wrapper}>
			<Typography className={classes.title}>{rep.label}</Typography>
			
			<div className={classes.progressBar}>
				<div 
					className={classes.progressFill}
					style={{ width: `${progress}%` }}
				/>
			</div>

			<div className={classes.rankInfo}>
				<span className={classes.currentRank}>
					{rep.current?.label ?? 'No Rank'}
				</span>
				<span className={classes.nextRank}>
					{rep.next?.label ?? 'Unknown'}
				</span>
			</div>
		</Paper>
	);
};
