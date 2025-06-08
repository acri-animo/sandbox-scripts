import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import loadable from '@loadable/component';
import { Box, Paper } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Navigation from './components/Navigation';
import TitleBar from './components/TitleBar';

import { useJobPermissions } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		background: '#0A0A0A',
		display: 'flex',
		flexDirection: 'column',
		position: 'relative',
		overflow: 'hidden',
		'&::before': {
			content: '""',
			position: 'absolute',
			top: 0,
			left: 0,
			right: 0,
			bottom: 0,
			background: 'radial-gradient(circle at 50% 50%, rgba(255, 255, 255, 0.05) 0%, transparent 70%)',
			pointerEvents: 'none',
		},
	},
	topBar: {
		height: 60,
		background: 'rgba(255, 255, 255, 0.03)',
		borderBottom: '1px solid rgba(255, 255, 255, 0.05)',
		display: 'flex',
		alignItems: 'center',
		padding: theme.spacing(0, 3),
		backdropFilter: 'blur(10px)',
		zIndex: 1,
	},
	content: {
		flex: 1,
		display: 'flex',
		overflow: 'hidden',
		position: 'relative',
	},
	sidebar: {
		width: 80,
		background: 'rgba(255, 255, 255, 0.02)',
		borderRight: '1px solid rgba(255, 255, 255, 0.05)',
		display: 'flex',
		flexDirection: 'column',
		transition: 'all 0.3s ease',
		'&:hover': {
			width: 240,
		},
	},
	mainContent: {
		flex: 1,
		overflow: 'auto',
		padding: theme.spacing(3),
		background: 'transparent',
	},
	emptyState: {
		height: '100%',
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		justifyContent: 'center',
		color: 'rgba(255, 255, 255, 0.7)',
		textAlign: 'center',
		padding: theme.spacing(4),
	},
	emptyIcon: {
		fontSize: 64,
		marginBottom: theme.spacing(2),
		color: 'rgba(255, 255, 255, 0.3)',
		animation: 'pulse 2s infinite',
	},
	emptyText: {
		fontSize: 20,
		fontWeight: 500,
		marginTop: theme.spacing(2),
		background: 'linear-gradient(45deg, #fff, rgba(255, 255, 255, 0.5))',
		WebkitBackgroundClip: 'text',
		WebkitTextFillColor: 'transparent',
	},
	'@keyframes pulse': {
		'0%': {
			transform: 'scale(1)',
			opacity: 0.3,
		},
		'50%': {
			transform: 'scale(1.1)',
			opacity: 0.5,
		},
		'100%': {
			transform: 'scale(1)',
			opacity: 0.3,
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const hasJobPerm = useJobPermissions();

	const [currentPage, setCurrentPage] = useState('Dashboard');
	const [currentData, setCurrentData] = useState(null);
	const [isSidebarHovered, setIsSidebarHovered] = useState(false);
	const pages = useSelector((state) => state.data.data.businessPages);
	const hasAccess = useSelector((state) => state.data.data.businessLogo);

	const onNav = async (id, data) => {
		if (pages && pages.find((p) => p.id == id)) {
			setCurrentData(data);
			setCurrentPage(id);
		} else {
			setCurrentData({});
			setCurrentPage('Dashboard');
		}
	};

	const getCurrentPage = () => {
		const Component = loadable(() => import(`./pages/${currentPage}`));
		return <Component onNav={onNav} data={currentData} />;
	};

	const pageComponent = useMemo(() => getCurrentPage(), [currentPage]);

	if (!hasAccess || !pages) {
		return (
			<div className={classes.wrapper}>
				<Box className={classes.emptyState}>
					<FontAwesomeIcon 
						icon={['fas', 'business-time']} 
						className={classes.emptyIcon}
					/>
					<div className={classes.emptyText}>
						Must Be Clocked In at a Participating Business
					</div>
				</Box>
			</div>
		);
	}

	return (
		<div className={classes.wrapper}>
			<div className={classes.topBar}>
				<TitleBar />
			</div>
			<div className={classes.content}>
				<div 
					className={classes.sidebar}
					onMouseEnter={() => setIsSidebarHovered(true)}
					onMouseLeave={() => setIsSidebarHovered(false)}
				>
					<Navigation
						current={currentPage}
						items={pages}
						onNavSelect={onNav}
						isExpanded={isSidebarHovered}
					/>
				</div>
				<div className={classes.mainContent}>
					{pageComponent}
				</div>
			</div>
		</div>
	);
};
