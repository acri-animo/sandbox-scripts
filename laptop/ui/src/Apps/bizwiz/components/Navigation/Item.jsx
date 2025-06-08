import React from 'react';
import { makeStyles } from '@mui/styles';
import { Box } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useStyles = makeStyles((theme) => ({
	item: {
		display: 'flex',
		alignItems: 'center',
		padding: theme.spacing(1, 2),
		color: 'rgba(255, 255, 255, 0.5)',
		cursor: 'pointer',
		transition: 'all 0.2s ease',
		borderRadius: theme.spacing(1),
		position: 'relative',
		overflow: 'hidden',
		'&::before': {
			content: '""',
			position: 'absolute',
			left: 0,
			top: 0,
			bottom: 0,
			width: 3,
			background: 'transparent',
			transition: 'background 0.2s ease',
		},
		'&:hover': {
			color: '#fff',
			background: 'rgba(255, 255, 255, 0.05)',
			'& .icon': {
				transform: 'scale(1.1)',
			},
		},
		'&.active': {
			color: '#fff',
			background: 'rgba(255, 255, 255, 0.08)',
			'&::before': {
				background: theme.palette.primary.main,
			},
			'& .icon': {
				color: theme.palette.primary.main,
			},
		},
	},
	icon: {
		width: 40,
		height: 40,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		transition: 'all 0.2s ease',
		'& svg': {
			fontSize: 18,
		},
	},
	label: {
		fontSize: 14,
		fontWeight: 500,
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		transition: 'all 0.2s ease',
		opacity: 0,
		width: 0,
		'&.expanded': {
			opacity: 1,
			width: 'auto',
			marginLeft: theme.spacing(2),
		},
	},
}));

export default ({ onClick, active, icon, label, isExpanded }) => {
	const classes = useStyles();

	return (
		<Box 
			className={`${classes.item} ${active ? 'active' : ''}`}
			onClick={onClick}
		>
			<div className={`${classes.icon} icon`}>
				<FontAwesomeIcon icon={icon} />
			</div>
			<div className={`${classes.label} ${isExpanded ? 'expanded' : ''}`}>
				{label}
			</div>
		</Box>
	);
};
