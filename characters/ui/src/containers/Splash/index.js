import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import { Fade } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
	faComputerMouse,
	faSpaceShuttle,
	faRightToBracket,
} from '@fortawesome/free-solid-svg-icons';

import Nui from '../../util/Nui';
import { GetData } from '../../util/NuiEvents';

import logo from '../../assets/imgs/mlogo.png';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignItems: 'center',
		position: 'absolute',
		top: '50%',
		left: '50%',
		transform: 'translate(-50%, -50%)',
		textAlign: 'center',
		fontFamily: ['Good Times Rg', 'sans-serif'].join(','),
		fontSize: 30,
		color: theme.palette.text.main,
		zIndex: 1000,
		padding: 36,
		borderRadius: '16px',
	},
	img: {
		width: '100%',
		maxWidth: '200px',
		height: 'auto',
	},
	splashTip: {
		marginTop: '5px',
		fontSize: '1rem',
		textAlign: 'center',
		background: 'rgba(0, 0, 0, 0.1)',
		padding: '10px',
		borderRadius: '8px',
		position: 'relative',
		overflow: 'hidden',
		'&:before': {
			content: '""',
			position: 'absolute',
			top: 0,
			left: 0,
			width: '100%',
			height: '100%',
			border: `2px solid ${theme.palette.primary.main}`,
			borderRadius: '8px',
			boxSizing: 'border-box',
			animation: '$borderFill 2.5s linear infinite',
			zIndex: -1,
			boxShadow: '0 0 8px rgba(25, 118, 210, 0.5)',
		},
	},
	splashTipHighlight: {
		fontWeight: 500,
		color: theme.palette.primary.main,
		display: 'inline-block',
		margin: '0 10px',
		textAlign: 'center',
		filter: 'drop-shadow(0 0 5px rgba(25, 118, 210, 0.3)) drop-shadow(0 0 10px rgba(25, 118, 210, 0.2))',
	},
	iconText: {
		display: 'block',
		marginTop: '5px',
		filter: 'drop-shadow(0 0 5px rgba(25, 118, 210, 0.3)) drop-shadow(0 0 10px rgba(25, 118, 210, 0.2))',
	},
	'@keyframes borderFill': {
		'0%': {
			clipPath: 'polygon(90% 0%, 100% 0%, 100% 10%, 90% 10%)',
		},
		'25%': {
			clipPath: 'polygon(90% 90%, 100% 90%, 100% 100%, 90% 100%)',
		},
		'50%': {
			clipPath: 'polygon(0% 90%, 10% 90%, 10% 100%, 0% 100%)',
		},
		'75%': {
			clipPath: 'polygon(0% 0%, 10% 0%, 10% 10%, 0% 10%)',
		},
		'100%': {
			clipPath: 'polygon(90% 0%, 100% 0%, 100% 10%, 90% 10%)',
		},
	},
	'@keyframes pulse': {
		'0%': {
			transform: 'scale(1)',
		},
		'50%': {
			transform: 'scale(1.02)',
		},
		'100%': {
			transform: 'scale(1)',
		},
	},
}));

export default (props) => {
	const dispatch = useDispatch();
	const classes = useStyles();

	const [show, setShow] = useState(true);

	const onAnimEnd = () => {
		Nui.send(GetData);
		dispatch({
			type: 'LOADING_SHOW',
			payload: { message: 'Loading Server Data' },
		});
	};

	const Bleh = (e) => {
		if (e.which == 1 || e.which == 13 || e.which == 32) {
			setShow(false);
		}
	};

	useEffect(() => {
		['click', 'keydown', 'keyup'].forEach(function (e) {
			window.addEventListener(e, Bleh);
		});

		return () => {
			['click', 'keydown', 'keyup'].forEach(function (e) {
				window.removeEventListener(e, Bleh);
			});
		};
	}, []);

	return (
		<Fade in={show} onExited={onAnimEnd}>
			<div className={classes.wrapper}>
				<img className={classes.img} src={logo} alt="logo" />
				<div className={classes.splashTip}>
					<span className={classes.splashTipHighlight}>
						<FontAwesomeIcon icon={faRightToBracket} />
						<span className={classes.iconText}>Enter</span>
					</span>
					<span className={classes.splashTipHighlight}>
						<FontAwesomeIcon icon={faSpaceShuttle} />
						<span className={classes.iconText}>Space</span>
					</span>
					<span className={classes.splashTipHighlight}>
						<FontAwesomeIcon icon={faComputerMouse} />
						<span className={classes.iconText}>Left Click</span>
					</span>
				</div>
			</div>
		</Fade>
	);
};
