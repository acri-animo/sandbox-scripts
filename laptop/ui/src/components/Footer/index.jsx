import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { useMyApps } from '../../hooks';

export default (props) => {
	const dispatch = useDispatch();
	const apps = useMyApps();
	const focused = useSelector((state) => state.apps.focused);
	const openApps = useSelector((state) => state.apps.appStates);

	const useStyles = makeStyles((theme) => ({
		taskbar: {
			height: '40px',
			width: 'auto',
			display: 'flex',
			background: 'rgba(32, 32, 32, 0.7)',
			backdropFilter: 'blur(10px)',
			position: 'absolute',
			bottom: '4px',
			left: '50%',
			transform: 'translateX(-50%)',
			borderRadius: '10px',
			padding: '0 15px',
			boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
			maxWidth: '90%',
			zIndex: 1000,
			opacity: 0,
			visibility: 'hidden',
			transition: 'all 0.3s ease',
			'&.visible': {
				opacity: 1,
				visibility: 'visible',
			},
		},
		appIcons: {
			height: '40px',
			display: 'flex',
			alignItems: 'center',
			gap: 8,
			overflow: 'hidden',
			padding: '0 10px',
		},
		appIcon: {
			minWidth: 40,
			height: 35,
			padding: 8,
			borderRadius: 10,
			display: 'flex',
			alignItems: 'center',
			justifyContent: 'center',
			'&.focused': {
				background: 'rgba(255, 255, 255, 0.1)',
				'& .MuiSvgIcon-root': {
					transform: 'scale(1.1)',
				},
			},
			'&:hover': {
				background: 'rgba(255, 255, 255, 0.05)',
			},
		},
		icon: {
			fontSize: 20,
			transition: 'transform 0.2s ease',
		},
	}));

	const classes = useStyles();

	const onClick = (app) => {
		if (focused == app) {
			dispatch({
				type: 'MINIMIZE_APP',
				payload: {
					app,
				},
			});
		} else {
			dispatch({
				type: 'UPDATE_APP_STATE',
				payload: {
					app,
					focus: true,
					state: {
						minimized: false,
					},
				},
			});
		}
	};

	return (
		<div className={`${classes.taskbar}${openApps.length > 0 ? ' visible' : ''}`}>
			<div className={classes.appIcons}>
				{openApps.map((appState) => {
					let appData = apps[appState.app];
					if (Boolean(appData)) {
						return (
							<Button
								key={`appstart-${appState.app}`}
								className={`${classes.appIcon}${
									focused == appState.app ? ' focused' : ''
								}`}
								onClick={() => onClick(appState.app)}
							>
								<FontAwesomeIcon
									className={classes.icon}
									icon={appData.icon}
									style={{ color: 'white' }}
								/>
							</Button>
						);
					} else return null;
				})}
			</div>
		</div>
	);
};
