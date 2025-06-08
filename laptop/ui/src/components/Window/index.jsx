import React, { useRef } from 'react';
import { Grid, Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Draggable from 'react-draggable'; // The default
import { useDispatch, useSelector } from 'react-redux';

export default ({
	title,
	children,
	app,
	appState,
	appData,
	onRefresh = null,
	color = false,
	width = '100%',
	height = '100%',
}) => {
	const dispatch = useDispatch();
	const focused = useSelector((state) => state.apps.focused);
	const useStyles = makeStyles((theme) => ({
		window: {
			position: 'absolute',
			height: appState.fullscreen ? '100%' : '90%',
			width: appState.fullscreen ? '100%' : '85%',
			left: appState.fullscreen ? '0 !important' : 150,
			top: appState.fullscreen ? '0 !important' : 40,
			transform: appState.fullscreen ? 'none !important' : undefined,
			zIndex: focused === app ? 200 : 100,
			border: !Boolean(appData.size)
			  ? 'none'
			  : `1px solid ${
				  focused === app
					? appData.color || theme.palette.primary.main
					: theme.palette.secondary.main
				}`,
			boxShadow: focused === app ? '0 6px 20px rgba(0,0,0,0.1)' : '0 3px 10px rgba(0,0,0,0.05)',
			overflow: 'hidden',
			backgroundColor: theme.palette.background.paper,
			transition: appState.fullscreen ? 'all 0.2s ease-out' : 'none',
			willChange: 'transform, width, height, left, top',
		},
		
		titlebar: {
			height: 50,
			width: '100%',
			/* background: focused === app
			  ? `linear-gradient(135deg, ${
				  Boolean(color) ? color : theme.palette.primary.main
				} 0%, ${
				  Boolean(color)
					? theme.palette.augmentColor({ color: { main: color } }).light
					: theme.palette.primary.light
				} 100%)`
			  : `linear-gradient(135deg, ${theme.palette.secondary.light} 0%, ${theme.palette.secondary.main} 100%)`, */
			display: 'flex',
			alignItems: 'center',
			justifyContent: 'space-between',
			padding: '0 16px',
			borderBottom: '1px solid rgba(0, 0, 0, 0.1)',
			userSelect: 'none',
			zIndex: focused === app ? 200 : 100,
			color: theme.palette.getContrastText(
			  focused === app
				? Boolean(color)
				  ? color
				  : theme.palette.primary.main
				: theme.palette.secondary.light
			),
			fontWeight: 400,
			fontSize: '1rem',
			transition: 'background 0.3s ease',
		},
		
		title: {
			flex: 1,
			fontWeight: 400,
			fontSize: '1.05rem',
			color: '#FFFFFF',
			letterSpacing: '0.3px',
			whiteSpace: 'nowrap',
			overflow: 'hidden',
			textOverflow: 'ellipsis',
		},
		
		actions: {
			display: 'flex',
			alignItems: 'center',
			gap: '0.5rem',
		},
		
		appControlMinimizeBtn: {
			border: `none`,
			minWidth: `17px`,
			minHeight: `17px`,
			borderRadius: `50px`,
			marginRight: '0.5rem',
			backgroundColor: `#FFBF60`,
			'&:hover': {
				cursor: 'pointer',
				transform: 'scale(1.1)',
				backgroundColor: `#FFBF60`,
			}
		},
		appControlFullscreenBtn: {
			border: `none`,
			minWidth: `17px`,
			minHeight: `17px`,
			borderRadius: `50px`,
			marginRight: '0.5rem',
			backgroundColor: `#60FF60`,
			'&:hover': {
				cursor: 'pointer',
				transform: 'scale(1.1)',
				backgroundColor: `#60FF60`,
				
			}
		},
		appControlCloseBtn: {
			border: `none`,
			minWidth: `17px`,
			minHeight: `17px`,
			borderRadius: `50px`,
			backgroundColor: `#FF6060`,
			'&:hover': {
				cursor: 'pointer',
				transform: 'scale(1.1)',
				backgroundColor: `#FF6060`,
			}
		},
		
		content: {
			height: 'calc(100% - 50px)',
			background: theme.palette.secondary.dark,
			borderTop: '1px solid rgba(255, 255, 255, 0.05)',
			padding: '1px',
			overflow: 'auto',
		},
		
		windowDrag: {
		visibility: appState.minimized ? 'hidden' : 'visible',
		},
		
	}));

	const classes = useStyles();

	const onStart = () => {
		if (focused != app) {
			dispatch({
				type: 'UPDATE_FOCUS',
				payload: {
					app,
				},
			});
		}
	};

	const onClick = () => {
		if (focused != app) {
			dispatch({
				type: 'UPDATE_FOCUS',
				payload: {
					app,
				},
			});
		}
	};

	const onMinimize = () => {
		dispatch({
			type: 'MINIMIZE_APP',
			payload: {
				app,
			},
		});
	};

	const onFullscreen = () => {
		// Reset window position when entering fullscreen
		if (!appState.fullscreen) {
			dispatch({
				type: 'UPDATE_APP_STATE',
				payload: {
					app,
					focus: true,
					state: {
						...appState,
						fullscreen: true,
						position: { x: 0, y: 0 } // Reset position to top-left
					},
				},
			});
		} else {
			dispatch({
				type: 'UPDATE_APP_STATE',
				payload: {
					app,
					focus: true,
					state: {
						...appState,
						fullscreen: false
					},
				},
			});
		}
	};

	const onClose = () => {
		dispatch({
			type: 'CLOSE_APP',
			payload: {
				app,
			},
		});
	};

	return (
		<Draggable
			handle={'section'}
			disabled={appState.fullscreen}
			bounds="parent"
		>
			<div className={`${classes.window} ${appState.minimized ? classes.windowDrag : ''}`} onClick={onClick}>
				<section className={classes.titlebar}>
					<div className={classes.title}>{title}</div>
					<div className={classes.actions}>
						{Boolean(onRefresh) && (
							<Button fullWidth className={classes.action}>
								<FontAwesomeIcon
									icon={['fas', 'arrows-rotate']}
								/>
							</Button>
						)}

						<div
							style={{
								marginRight: '1vh'
							}}
						>
							<Button className={classes.appControlMinimizeBtn} onClick={onMinimize}>
								<div></div>
							</Button>
							<Button className={classes.appControlFullscreenBtn} onClick={onFullscreen}>
								<div></div>
							</Button>
							<Button onClick={onClose} className={classes.appControlCloseBtn}>
								<div></div>
							</Button>
						</div>
					</div>
				</section>
				<div className={classes.content}>{children}</div>
			</div>
		</Draggable>
	);
};