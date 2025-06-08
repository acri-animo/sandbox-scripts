import React, { useState, useEffect } from 'react';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Moment from 'react-moment';
import { useMyStates } from '../../hooks';
import InstallPopover from './InstallPopover';

const useStyles = makeStyles((theme) => ({
	header: {
		background: 'rgba(32, 32, 32, 0.8)',
		height: '40px',
		width: 'auto',
		minWidth: '250px',
		position: 'absolute',
		right: '10px',
		bottom: '4px',
		zIndex: 999,
		fontSize: '16px',
		lineHeight: '40px',
		padding: '0 15px',
		userSelect: 'none',
		borderRadius: '10px',
		backdropFilter: 'blur(5px)',
		boxShadow: '0 2px 10px rgba(0, 0, 0, 0.2)',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
		fontFamily: 'Oswald, sans-serif',
	},
	hLeft: {
		color: theme.palette.text.light,
		marginRight: '15px',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		lineHeight: '1.2',
		fontFamily: 'Oswald, sans-serif',
	},
	time: {
		fontSize: '14px',
		fontFamily: 'Oswald, sans-serif',
	},
	date: {
		fontSize: '12px',
		color: theme.palette.text.main,
		fontFamily: 'Oswald, sans-serif',
	},
	hRight: {
		display: 'flex',
		alignItems: 'center',
		gap: '10px',
	},
	headerIcon: {
		'&.clickable': {
			transition: 'color ease-in 0.15s',
			cursor: 'pointer',
			'&:hover': {
				color: theme.palette.primary.main,
			},
		},
		'&.wifi': {
			color: theme.palette.text.main,
		},
		'&.race': {
			color: theme.palette.info.main,
		},
	},
}));

export default function Header() {
	const classes = useStyles();
	const [currentTime, setCurrentTime] = useState(new Date());
	const [anchorEl, setAnchorEl] = useState(null);
	const hasState = useMyStates();

	useEffect(() => {
		const timer = setInterval(() => {
			setCurrentTime(new Date());
		}, 1000);

		return () => clearInterval(timer);
	}, []);

	const handlePopoverOpen = (event) => {
		setAnchorEl(event.currentTarget);
	};

	const handlePopoverClose = () => {
		setAnchorEl(null);
	};

	const hasAnyUsb = [
		'LAPTOP_RACER_USB',
		'LAPTOP_UNDG_USB',
		'LAPTOP_GANG_USB',
	].some((state) => hasState(state));

	return (
		<div className={classes.header}>
			<div className={classes.hLeft}>
				<div className={classes.time}>
					{currentTime.getHours().toString().padStart(2, '0')}:
					{currentTime.getMinutes().toString().padStart(2, '0')}
				</div>
				<div className={classes.date}>
					<Moment format="MM/DD/YYYY" />
				</div>
			</div>
			<div className={classes.hRight}>
				{hasAnyUsb && (
					<FontAwesomeIcon
						className={`${classes.headerIcon} clickable`}
						icon="usb-drive"
						onClick={handlePopoverOpen}
					/>
				)}
				{hasState('RACE_DONGLE') && (
					<FontAwesomeIcon
						className={`${classes.headerIcon} race`}
						icon="flag-checkered"
					/>
				)}
				<FontAwesomeIcon
					className={`${classes.headerIcon} wifi`}
					icon="wifi"
				/>
				<FontAwesomeIcon className={classes.headerIcon} icon="signal" />
				{hasAnyUsb && (
					<InstallPopover
						anchorEl={anchorEl}
						onClose={handlePopoverClose}
						hasState={hasState}
					/>
				)}
			</div>
		</div>
	);
}
