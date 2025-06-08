import React from 'react';
import { makeStyles } from '@mui/styles';
import { Slide } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faThumbtack } from '@fortawesome/free-solid-svg-icons';

const useStyles = makeStyles((theme) => ({
	container: {
		position: 'absolute',
		top: '5%',
		height: 40,
		width: 'fit-content',
		pointerEvents: 'none',
		display: 'flex',
		zIndex: 1,
		background: `${theme.palette.secondary.dark}90`,
		'& small': {
			fontSize: 12,
			display: 'block',
			lineHeight: '40px',
			padding: '0 5px',
		},
	},
	label: {
		color: theme.palette.text.light,
		fontSize: 18,
		lineHeight: '40px',
		textShadow: '0 0 5px #000',
		paddingLeft: 1,
		paddingRight: 15,
		flex: 1,
		height: 'fit-content',
		display: 'flex',
		alignItems: 'center',
	},
	icon: {
		color: theme.palette.primary.main,
		fontSize: 18,
		lineHeight: '40px',
		padding: '0 10px',
	},
}));

export default ({ message }) => {
	const classes = useStyles();
	return (
		<Slide direction="right" in={true}>
			<div className={classes.container}>
				<div className={classes.icon}>
					<FontAwesomeIcon icon={faThumbtack} />
				</div>
				<div className={classes.label}>{message}</div>
			</div>
		</Slide>
	);
};
