/* eslint-disable react/prop-types */
import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
	Fade,
	ListItemButton,
	ListItemIcon,
	ListItemText,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { SelectSpawn } from '../../../util/NuiEvents';
import Nui from '../../../util/Nui';

const useStyles = makeStyles((theme) => ({
	container: {
		width: '375px',
		borderRadius: '8px',
		background: `${theme.palette.secondary.main}90`,
		'&:hover': {
			background: theme.palette.action.hover,
		},
	},
	active: {
		background: theme.palette.primary.main,
		'&:hover': {
			background: theme.palette.primary.main,
		},
	},
	spawnIcon: {
		fontSize: 20,
		color: theme.palette.text.primary,
	},
}));

export default ({ spawn, onPlay }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const selected = useSelector((state) => state.spawn.selected);

	const onClick = () => {
		Nui.send(SelectSpawn, { spawn });
		dispatch({
			type: 'SELECT_SPAWN',
			payload: spawn,
		});
	};

	const isActive = selected?.id === spawn?.id;

	return (
		<Fade in={true}>
			<ListItemButton
				className={`${classes.container} ${
					isActive ? classes.active : ''
				}`}
				onClick={onClick}
				onDoubleClick={onPlay}
			>
				<ListItemIcon className={classes.spawnIcon}>
					<FontAwesomeIcon
						icon={Boolean(spawn.icon) ? spawn.icon : 'location-dot'}
					/>
				</ListItemIcon>
				<ListItemText primary={spawn.label} />
			</ListItemButton>
		</Fade>
	);
};
