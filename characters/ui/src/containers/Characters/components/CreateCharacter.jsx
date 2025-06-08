/* eslint-disable react/prop-types */
import React from 'react';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { useDispatch } from 'react-redux';

import { STATE_CREATE } from '../../../util/States';

const useStyles = makeStyles((theme) => ({
	container: {
		width: 185,
		height: 100,
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		borderRadius: 10,
		cursor: 'pointer',
		textAlign: 'center',
		transition: 'transform 0.2s ease',
		'&:hover': {
			transform: 'translateY(-2px)',
		},
	},
	details: {
		display: 'flex',
		alignItems: 'center',
		gap: 10,
		fontSize: 22,
		color: 'white',
		fontWeight: 'bold',
	},
	icon: {
		color: theme.palette.success.main,
		fontSize: 28,
	},
}));

export default () => {
	const classes = useStyles();
	const dispatch = useDispatch();

	const onClick = () => {
		dispatch({
			type: 'SET_STATE',
			payload: { state: STATE_CREATE },
		});
	};

	return (
		<Fade in={true}>
			<div className={classes.container} onClick={onClick}>
				<div className={classes.details}>
					<i className={`fa-solid fa-circle-plus ${classes.icon}`} />
					<span>New Character</span>
				</div>
			</div>
		</Fade>
	);
};
