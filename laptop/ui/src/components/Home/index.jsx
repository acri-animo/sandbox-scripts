import React, { useEffect, useState } from 'react';
import { connect, useDispatch, useSelector } from 'react-redux';
import { Menu, MenuItem, Avatar, Badge } from '@mui/material';
import { makeStyles, withStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import chroma from 'chroma-js'; // Ensure you install chroma-js: npm install chroma-js
//import NestedMenuItem from 'material-ui-nested-menu-item';

import {
	useAlert,
	useAppView,
	useAppButton,
	useReorder,
	useMyApps,
} from '../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		userSelect: 'none',
		zIndex: 0,
	},
	grid: {
		display: 'flex',
		flexFlow: 'column wrap',
		height: '100%',
		width: '100%',
		padding: 10,
		justifyContent: 'flex-start',
		alignContent: 'flex-start',
		overflow: 'hidden',
	},
	appBtn: {
		width: 80,
		height: 100,
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		textAlign: 'center',
		height: 'fit-content',
		padding: 10,
		borderRadius: 10,
		position: 'relative',
		zIndex: 5,
		marginRight: 10,
		marginBottom: 10,
		'&:hover:not(.fake)': {
			transition: 'background ease-in 0.15s',
			background: `${theme.palette.primary.main}40`,
			cursor: 'pointer',
		},
	},
	appIcon: {
		fontSize: 30,
		width: 60,
		height: 60,
		margin: 'auto',
		color: '#fff',
		borderRadius: '35%', // Make the icon circular
		backgroundColor: '#3f51b5', // Add a background color
		/* border: '2px solid #fff', // Add a white border */
		boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)', // Add a subtle shadow
		transition: 'transform 0.3s ease', // Add a transition for hover effect
		'&:hover': {
			transform: 'scale(1.1)', // Slightly enlarge on hover
		},
	},
	appLabel: {
		fontSize: 12,
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		textShadow: '0px 0px 5px #000000',
		fontWeight: 'normal',
		marginTop: 10,
		pointerEvents: 'none',
		fontFamily: 'Oswald, sans-serif',
		fontSize: 14,
	},
}));

const NotifCount = withStyles((theme) => ({
	root: {
		width: 24,
		height: 24,
		fontSize: 16,
		lineHeight: '24px',
		color: '#fff',
		background: '#ff0000',
	},
}))(Avatar);

export default (props) => {
	const openedApp = useAppView();
	const classes = useStyles();
	const dispatch = useDispatch();
	const apps = useMyApps();

	const homeApps = useSelector((state) => state.data.data.player?.LaptopApps?.home);

	useEffect(() => {
		dispatch({
			type: 'NOTIF_RESET_APP',
		});
	}, []);

	const onClick = (e, app) => {
		e.preventDefault();

		if (!apps?.[app]?.fake) {
			openedApp(app);
		}
	};

	return (
		<div className={classes.wrapper}>
			<div className={classes.grid}>
				{Object.keys(apps).length > 0
					? homeApps.map((app, i) => {
							let data = apps[app];
							if (data) {
								return (
									<div
										key={i}
										className={`${classes.appBtn} ${data.fake ? 'fake' : null}`}
										title={data.label}
										onClick={(e) => onClick(e, app)}
									>
										{data.unread > 0 ? (
											<Badge
												overlap="circle"
												anchorOrigin={{
													vertical: 'bottom',
													horizontal: 'right',
												}}
												badgeContent={
													<NotifCount
														style={{
															border: `2px solid ${data.color}`,
														}}
													>
														{data.unread}
													</NotifCount>
												}
											>
												<Avatar
													variant="rounded"
													className={classes.appIcon}
													style={{
														background: `${data.color}`,
													}}
												>
													<FontAwesomeIcon
														icon={data.icon}
													/>
												</Avatar>
											</Badge>
										) : (
											<Avatar
												variant="rounded"
												className={classes.appIcon}
												style={{
													background: `linear-gradient(45deg, ${data.color}, ${chroma(data.color).brighten(2.2).hex()})`,
												}}
											>
												<FontAwesomeIcon
													icon={data.icon}
												/>
											</Avatar>
										)}
										<div className={classes.appLabel}>
											{data.label}
										</div>
									</div>
								);
							} else return null;
					  })
					: null}
			</div>
		</div>
	);
};
