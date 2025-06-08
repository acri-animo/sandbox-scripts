import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { Box } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Item from './Item';
import { useJobPermissions } from '../../../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		flex: 1,
		display: 'flex',
		flexDirection: 'column',
		overflow: 'hidden',
	},
	scrollContainer: {
		flex: 1,
		overflowY: 'auto',
		overflowX: 'hidden',
		padding: theme.spacing(2, 0),
		'&::-webkit-scrollbar': {
			width: 0,
			transition: 'width 0.2s ease',
		},
		'&::-webkit-scrollbar-track': {
			background: 'rgba(255, 255, 255, 0.05)',
			borderRadius: 3,
		},
		'&::-webkit-scrollbar-thumb': {
			background: 'rgba(255, 255, 255, 0.1)',
			borderRadius: 3,
			'&:hover': {
				background: 'rgba(255, 255, 255, 0.2)',
			},
		},
		'&.expanded': {
			'&::-webkit-scrollbar': {
				width: 6,
			},
		},
	},
	section: {
		marginBottom: theme.spacing(3),
		'&:last-child': {
			marginBottom: 0,
		},
	},
	sectionTitle: {
		padding: theme.spacing(1, 2),
		fontSize: 10,
		fontWeight: 600,
		textTransform: 'uppercase',
		letterSpacing: 2,
		color: 'rgba(255, 255, 255, 0.3)',
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		opacity: 0,
		transition: 'opacity 0.2s ease',
		'&.expanded': {
			opacity: 1,
		},
	},
	items: {
		display: 'flex',
		flexDirection: 'column',
		gap: theme.spacing(1),
	},
}));

export default ({ onNavSelect, current, items, isExpanded }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const hasJobPerm = useJobPermissions();
	const onDuty = useSelector((state) => state.data.data.onDuty);

	const onClick = (id) => {
		onNavSelect(id);
	};

	// Group items by category if they have one
	const groupedItems = items.reduce((acc, item) => {
		const category = item.category || 'Main';
		if (!acc[category]) {
			acc[category] = [];
		}
		acc[category].push(item);
		return acc;
	}, {});

	return (
		<Box className={classes.wrapper}>
			<div className={`${classes.scrollContainer} ${isExpanded ? 'expanded' : ''}`}>
				{Object.entries(groupedItems).map(([category, categoryItems]) => (
					<div key={category} className={classes.section}>
						{category !== 'Main' && (
							<div className={`${classes.sectionTitle} ${isExpanded ? 'expanded' : ''}`}>
								{category}
							</div>
						)}
						<div className={classes.items}>
							{categoryItems
								.filter(
									(item) =>
										!item.hidden &&
										(!item.permission ||
											hasJobPerm(item.permission, onDuty))
								)
								.map((item) => (
									<Item
										key={item.id}
										id={item.id}
										icon={item.icon}
										label={item.label}
										active={item.id === current}
										onClick={() => onClick(item.id)}
										isExpanded={isExpanded}
									/>
								))}
						</div>
					</div>
				))}
			</div>
		</Box>
	);
};
