import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { Popover, LinearProgress } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Nui from '../../util/Nui';
import { useAlert } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	popover: {
		'& .MuiPaper-root': {
			marginTop: theme.spacing(-3),
			background: theme.palette.secondary.main,
		},
	},
	popoverContent: {
		display: 'flex',
		alignItems: 'center',
		padding: theme.spacing(1.5, 2),
		background: theme.palette.secondary.dark,
		color: theme.palette.text.primary,
		fontFamily: 'Oswald, sans-serif',
		fontSize: 14,
		fontWeight: 400,
		borderBottom: `1px solid ${theme.palette.divider}`,
		transition: 'background 0.2s ease, transform 0.1s ease',
		cursor: 'pointer',
		position: 'relative',
		'&:last-child': {
			borderBottom: 'none',
		},
		'&:hover': {
			background: theme.palette.secondary.light,
		},
		'&:active': {
			background: theme.palette.secondary.main,
		},
		'&.installing': {
			pointerEvents: 'none',
			opacity: 0.7,
		},
	},
	popoverIcon: {
		marginRight: theme.spacing(1.5),
		color: theme.palette.text.secondary,
		fontSize: 16,
	},
	popoverText: {
		flex: 1,
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
	},
	progressBar: {
		position: 'absolute',
		bottom: 0,
		left: 0,
		width: '100%',
		height: 4,
	},
}));

export default function AppInstallPopover({ anchorEl, onClose, hasState }) {
	const classes = useStyles();
	const showAlert = useAlert();
	const [progress, setProgress] = useState({});
	const currentApps = useSelector(
		(state) => state.data.data.player?.LaptopApps.installed || [],
	);
	const homeApps = useSelector(
		(state) => state.data.data.player?.LaptopApps.home || [],
	);

	const usbConfigs = [
		{
			state: 'LAPTOP_RACER_USB',
			app: 'redline',
			icon: 'flag-checkered',
			text: 'Install Redline',
		},
		{
			state: 'LAPTOP_UNDG_USB',
			app: 'lsunderground',
			icon: 'user-secret',
			text: 'Install Underground',
		},
		{
			state: 'LAPTOP_GANG_USB',
			app: 'gangs',
			icon: 'users-rays',
			text: 'Install Gangs',
		},
	];

	const activeUsbs = usbConfigs.filter((usb) => hasState(usb.state));

	const handleInstallClick = async (usbType) => {
		try {
			let res = await (
				await Nui.send('laptopinstallapp', {
					app: usbType,
				})
			).json();
			if (res && res.success) {
				showAlert('Installation Successful');
			} else {
				showAlert('Installation Failed');
			}
		} catch (err) {
			console.error(err);
			showAlert('Installation Failed');
		}
	};

	const startProgress = (usbState) => {
		const usbConfig = usbConfigs.find((usb) => usb.state === usbState);
		if (!usbConfig) {
			showAlert('Invalid USB App');
			return;
		}

		if (
			currentApps.includes(usbConfig.app) ||
			homeApps.includes(usbConfig.app)
		) {
			showAlert('App is already installed');
			return;
		}
		setProgress((prev) => ({ ...prev, [usbState]: 0 }));

		const duration = 10000;
		const increment = 100 / (duration / 16);
		let currentProgress = 0;

		const interval = setInterval(() => {
			currentProgress += increment;
			setProgress((prev) => ({
				...prev,
				[usbState]: Math.min(currentProgress, 100),
			}));

			if (currentProgress >= 100) {
				clearInterval(interval);
				handleInstallClick(usbConfig.app);
				setProgress((prev) => {
					const newProgress = { ...prev };
					delete newProgress[usbState];
					return newProgress;
				});
			}
		}, 16);
	};

	return (
		<Popover
			className={classes.popover}
			open={Boolean(anchorEl)}
			anchorEl={anchorEl}
			onClose={onClose}
			anchorOrigin={{
				vertical: 'top',
				horizontal: 'center',
			}}
			transformOrigin={{
				vertical: 'bottom',
				horizontal: 'center',
			}}
			disableRestoreFocus
		>
			{activeUsbs.map((usb) => (
				<div
					key={usb.state}
					className={`${classes.popoverContent} ${
						progress[usb.state] !== undefined ? 'installing' : ''
					}`}
					onClick={() => startProgress(usb.state)}
				>
					<FontAwesomeIcon
						className={classes.popoverIcon}
						icon={usb.icon}
					/>
					<span className={classes.popoverText}>{usb.text}</span>
					{progress[usb.state] !== undefined && (
						<LinearProgress
							variant="determinate"
							value={progress[usb.state]}
							className={classes.progressBar}
							color="primary"
						/>
					)}
				</div>
			))}
		</Popover>
	);
}
