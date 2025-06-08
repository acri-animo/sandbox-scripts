import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Slide } from '@mui/material';
import { makeStyles } from '@mui/styles';

import { Header, Footer, Home, Alerts, Notifications } from '../../components';
import { Wallpapers } from '../../util/Wallpapers';

import Popups from '../../components/Popups';
import AppHandler from '../AppHandler';

export default (props) => {
	const dispatch = useDispatch();
	const visible = useSelector((state) => state.laptop.visible);
	const player = useSelector((state) => state.data.data.player);
	const settings = useSelector(
		(state) => state.data.data.player?.LaptopSettings,
	);

	const clear = useSelector((state) => state.laptop.clear);
	useEffect(() => {
		if (clear) {
			setTimeout(() => {
				dispatch({ type: 'CLEARED_HISTORY' });
			}, 2000);
		}
	}, [clear]);

	const useStyles = makeStyles((theme) => ({
		wrapper: {
			maxHeight: 1000,
			height: '100%',
			maxWidth: 1600,
			width: '100%',
			position: 'absolute',
			top: 0,
			bottom: 0,
			left: 0,
			right: 0,
			margin: 'auto',
			overflow: 'hidden',
			borderRadius: 16,
			border: '4px solid #2a2a2a',
			'&::before': {
				content: '""',
				position: 'absolute',
				top: 0,
				left: 0,
				right: 0,
				height: 20,
				background: 'rgb(32, 32, 32)',
				borderRadius: '4px 4px 0 0',
				zIndex: 1,
			},
			'&::after': {
				content: '""',
				position: 'absolute',
				bottom: 0,
				left: 0,
				right: 0,
				height: 20,
				background: 'rgb(32, 32, 32)',
				borderRadius: '0 0 4px 4px',
				zIndex: 1,
			},
		},
		laptopWallpaper: {
			height: '100%',
			width: '100%',
			position: 'absolute',
			background: `transparent no-repeat fixed center cover`,
			zIndex: -1,
			userSelect: 'none',
			opacity: 0.9,
			transition: 'opacity 0.3s ease-in-out',
		},
		laptop: {
			position: 'absolute',
			top: 20,
			left: 0,
			right: 0,
			bottom: 20,
			margin: 'auto',
			height: 'calc(100% - 40px)',
			width: '100%',
			overflow: 'hidden',
			borderRadius: 2,
		},
		screen: {
			height: 'calc(100% - 50px)',
			width: '100%',
			overflow: 'hidden',
			position: 'relative',
			backdropFilter: 'blur(2px)',
		},
		webcam: {
			position: 'absolute',
			top: 6,
			left: '50%',
			transform: 'translateX(-50%)',
			width: 6,
			height: 6,
			background: '#000',
			borderRadius: '50%',
			zIndex: 2,
			'&::before': {
				content: '""',
				position: 'absolute',
				top: 1,
				left: 1,
				right: 1,
				bottom: 1,
				background: '#1a1a1a',
				borderRadius: '50%',
			},
		},
		bottomBar: {
			position: 'absolute',
			bottom: 0,
			left: 0,
			right: 0,
			height: 50,
			background: 'rgba(32, 32, 32, 0.8)',
			backdropFilter: 'blur(5px)',
			display: 'flex',
			alignItems: 'center',
			justifyContent: 'space-between',
			padding: '0 20px',
			zIndex: 1000,
		},
	}));
	const classes = useStyles();

	if (!Boolean(player) || !Boolean(settings)) return null;
	return (
		<Slide direction="up" in={visible} mountOnEnter timeout={600}>
			<div className={classes.wrapper}>
				<div className={classes.webcam} />
				<div className={classes.laptop}>
					<img
						className={classes.laptopWallpaper}
						src={
							Wallpapers[settings.wallpaper] != null
								? Wallpapers[settings.wallpaper].file
								: settings.wallpaper
						}
					/>
					<Alerts />
					<Popups />
					<div className={classes.screen}>
						<AppHandler />
						<Home />
					</div>
					<div className={classes.bottomBar}>
						<Header />
						<Footer />
					</div>
				</div>
			</div>
		</Slide>
	);
};
