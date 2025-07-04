import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import { AppBar, Grid, Tooltip, IconButton } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { Loader } from '../../components';
import Reputation from './component/Reputation';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '95%',
		background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
	},
	header: {
		background: theme.palette.primary.main,
		fontSize: 20,
		padding: 15,
		lineHeight: '45px',
		height: 78,
	},
	headerAction: {
		textAlign: 'right',
		'&:hover': {
			color: theme.palette.text.main,
			transition: 'color ease-in 0.15s',
		},
	},
	body: {
		padding: 10,
		height: '88.75%',
		overflowY: 'auto',
		overflowX: 'hidden',
		'&::-webkit-scrollbar': {
			width: 6,
		},
		'&::-webkit-scrollbar-thumb': {
			background: '#ffffff52',
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: theme.palette.primary.main,
		},
		'&::-webkit-scrollbar-track': {
			background: 'transparent',
		},
	},
	emptyMsg: {
		width: '100%',
		textAlign: 'center',
		fontSize: 20,
		fontWeight: 'bold',
		marginTop: '25%',
	},
}));

const lsuReps = ['Chopping', 'Racing'];

export default ({ myReputations, loading, onRefresh }) => {
	const classes = useStyles();

	const theseReputions = myReputations?.filter(r => lsuReps.includes(r.id));

	return (
		<div className={classes.wrapper}>
			<div className={classes.body}>
				{!Boolean(theseReputions) ? (
					<Loader static text="Loading" />
				) : theseReputions.length > 0 ? (
					theseReputions.map((rep) => {
						return (
							<Reputation
								key={`lsu-${rep.id}`}
								rep={rep}
								disabled={loading}
							/>
						);
					})
				) : (
					<div className={classes.emptyMsg}>No Reputation Built</div>
				)}
			</div>
		</div>
	);
};
