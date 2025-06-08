import React, { useState } from 'react';
import { makeStyles, withStyles } from '@mui/styles';
import { Tab, Tabs } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Home from './Home';
import Invites from './Invites';
import History from './History';
import Tracks from './Tracks';
import New from './New';
import Admin from './Admin';
import View from './View';
import Profile from './Profile';

export const TrackTypes = {
	laps: 'Laps',
	p2p: 'Point to Point',
};

export const AccessTypes = [
	{ value: 'public', label: 'Public Join', disabled: false },
	{ value: 'team', label: 'Team Only', disabled: true },
	{ value: 'invite', label: 'Invite Only', disabled: false },
];

export const GhostTypes = [
	{ value: 'none', label: 'No Phasing' },
	{ value: 'timed', label: 'Ghosted For Period of Time' },
	{ value: 'checkpoints', label: 'Ghosted For # of Checkpoints' },
];

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		width: '100%',
		background: '#1a1a2e',
		display: 'flex',
		flexDirection: 'row',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
	},
	header: {
		background: '#242447',
		width: 140,
		height: '100%',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
		padding: '20px 0',
		order: 1,
		borderRight: '2px solid #8685EF',
	},
	content: {
		height: '100%',
		width: 'calc(100% - 140px)',
		overflow: 'hidden',
		order: 2,
		background: '#16213e',
	},
	tabPanel: {
		height: '100%',
		width: '100%',
		padding: '20px',
		boxSizing: 'border-box',
	},
	'@global': {
		'.MuiMenu-paper': {
			backgroundColor: '#1a1a2e !important',
			border: '1px solid rgba(134, 133, 239, 0.3) !important',
			borderRadius: '8px !important',
			boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3) !important',
			marginTop: '4px !important',
			padding: '6px !important',
		},
		'.MuiMenuItem-root': {
			color: 'white !important',
			fontSize: '14px !important',
			padding: '10px 16px !important',
			borderRadius: '4px !important',
			margin: '2px 0 !important',
			transition: 'all 0.2s ease !important',
			'&:hover': {
				backgroundColor: 'rgba(134, 133, 239, 0.2) !important',
			},
			'&.Mui-selected': {
				backgroundColor: 'rgba(134, 133, 239, 0.3) !important',
				color: '#8685EF !important',
				fontWeight: '500 !important',
				'&:hover': {
					backgroundColor: 'rgba(134, 133, 239, 0.4) !important',
				},
			},
		},
	},
}));

const YPTabs = withStyles((theme) => ({
	root: {
		border: 'none',
		width: '100%',
	},
	indicator: {
		backgroundColor: '#8685EF',
		right: 0,
		width: '4px',
		borderRadius: '2px 0 0 2px',
	},
}))((props) => <Tabs {...props} />);

const YPTab = withStyles((theme) => ({
	root: {
		minWidth: 'auto',
		padding: '16px 20px',
		margin: '4px 8px',
		borderRadius: '8px',
		color: 'rgba(255, 255, 255, 0.7)',
		fontSize: '0.875rem',
		fontWeight: '500',
		textTransform: 'none',
		transition: 'all 0.2s ease',
		willChange: 'transform, background-color, color',
		'&:hover': {
			color: '#8685EF',
			backgroundColor: 'rgba(134, 133, 239, 0.15)',
			transform: 'translateX(4px)',
		},
		'&$selected': {
			color: '#ffffff',
			backgroundColor: 'rgba(134, 133, 239, 0.25)',
			fontWeight: '600',
			transform: 'translateX(6px)',
		},
		'&:focus': {
			color: '#8685EF',
		},
		'& .MuiTab-wrapper': {
			flexDirection: 'row',
			justifyContent: 'flex-start',
			alignItems: 'center',
			gap: '12px',
		},
		'& svg': {
			fontSize: '1.1rem',
		},
	},
	selected: {},
	disabled: {
		color: 'rgba(255, 255, 255, 0.3) !important',
		backgroundColor: 'rgba(255, 255, 255, 0.05)',
	},
}))((props) => <Tab {...props} />);

const staticTabs = [
	{ label: 'Home', icon: ['fas', 'home'], component: Home },
	{ label: 'Invites', icon: ['fas', 'user-friends'], component: Invites },
	{ label: 'History', icon: ['fas', 'history'], component: History },
	{ label: 'Tracks', icon: ['fas', 'flag-checkered'], component: Tracks },
	{ label: 'New', icon: ['fas', 'plus'], component: New },
	{ label: 'Admin', icon: ['fas', 'cog'], component: Admin },
];

export default () => {
	const classes = useStyles();
	const [tab, setTab] = useState(0);
	const [dynamicTabs, setDynamicTabs] = useState([]);

	const handleTabChange = (event, newTab) => {
		setTab(newTab);
	};

	const handleViewRace = (raceId) => {
		const closeViewTab = () => {
			setDynamicTabs([]);
			setTab(0);
		};
		setDynamicTabs([
			{
				label: 'Race View',
				icon: ['fas', 'eye'],
				component: () => (
					<View
						id={raceId}
						onClose={closeViewTab}
						onViewProfile={handleViewProfile}
					/>
				),
			},
		]);
		setTab(staticTabs.length);
	};

	const handleViewProfile = (name, sid) => {
		const closeViewTab = () => {
			setDynamicTabs([]);
			setTab(0);
		};
		setDynamicTabs([
			{
				label: 'Profile View',
				icon: ['fas', 'eye'],
				component: () => (
					<Profile
						alias={name}
						racerSID={sid}
						onClose={closeViewTab}
						onViewRace={handleViewRace}
					/>
				),
			},
		]);
		setTab(staticTabs.length);
	};

	const allTabs = [...staticTabs, ...dynamicTabs];

	return (
		<div className={classes.wrapper}>
			<div className={classes.header}>
				<YPTabs
					value={tab}
					onChange={handleTabChange}
					scrollButtons={false}
					orientation="vertical"
				>
					{allTabs.map((t) => (
						<YPTab
							key={t.label}
							icon={<FontAwesomeIcon icon={t.icon} />}
							label={t.label}
						/>
					))}
				</YPTabs>
			</div>
			<div className={classes.content}>
				{allTabs.map((t, index) => (
					<div
						key={t.label}
						className={classes.tabPanel}
						role="tabpanel"
						hidden={tab !== index}
						id={t.label.toLowerCase().replace(' ', '-')}
					>
						{tab === index && (
							<t.component
								{...(t.label === 'Home'
									? {
											onViewRace: handleViewRace,
											onViewProfile: handleViewProfile,
									  }
									: {})}
								{...(t.label === 'Invites' || t.label === 'New'
									? { onViewRace: handleViewRace }
									: {})}
								{...(t.label === 'History'
									? {
											onViewRace: handleViewRace,
											onViewProfile: handleViewProfile,
									  }
									: {})}
								{...(t.label === 'Tracks'
									? { onViewProfile: handleViewProfile }
									: {})}
								{...(t.label === 'View'
									? { onViewProfile: handleViewProfile }
									: {})}
							/>
						)}
					</div>
				))}
			</div>
		</div>
	);
};
