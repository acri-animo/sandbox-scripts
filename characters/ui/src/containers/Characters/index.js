import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { makeStyles } from '@mui/styles';
import Drawer from '@mui/material/Drawer';
import Button from '@mui/material/Button';

import { Motd } from '../../components';
import CharacterButton from './components/CharacterButton';
import { STATE_CREATE } from '../../util/States';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCircleUser, faPlus } from '@fortawesome/pro-regular-svg-icons';

const useStyles = makeStyles((theme) => ({
	canvas: {
		height: '100vh',
		width: '100vw',
		position: 'relative',
	},
	buttonContainer: {
		position: 'absolute',
		bottom: '20px',
		left: '20px',
		display: 'flex',
		flexDirection: 'row',
		gap: '10px',
	},
	createChar: {
		position: 'absolute',
		top: '30%',
		left: '1%',
		display: 'flex',
		alignItems: 'center',
		gap: '10px',
	},
	infoIcon: {
		right: '15px',
		bottom: '30px',
		width: '20px',
		height: '20px',
		backgroundColor: theme.palette.secondary.light,
		color: 'white',
		borderRadius: '50%',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		fontSize: '12px',
		position: 'absolute',
	},
	tooltip: {
		display: 'none',
		position: 'absolute',
		backgroundColor: theme.palette.secondary.light,
		color: 'white',
		padding: '5px 10px',
		borderRadius: '5px',
		fontSize: '12px',
		bottom: '0px',
		right: '30px',
		zIndex: 1000,
		width: '200px',
		textAlign: 'center',
		boxShadow: theme.shadows[2],
	},
	infoIconHover: {
		'&:hover $tooltip': {
			display: 'block',
		},
	},
	drawerPaper: {
		width: '350px',
		padding: theme.spacing(2),
		background: `${theme.palette.secondary.dark}60`,
	},
	characterList: {
		display: 'flex',
		flexDirection: 'column',
		gap: '10px',
	},
	characterButtonWrapper: {
		width: '100%',
		height: '100px',
		marginTop: '30px',
		marginBottom: '30px',
		color: 'white',
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		borderRadius: '5px',
		cursor: 'pointer',
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const [drawerOpen, setDrawerOpen] = useState(false);

	const characters = useSelector((state) => state.characters.characters);
	const characterLimit = useSelector(
		(state) => state.characters.characterLimit,
	);
	const motd = useSelector((state) => state.characters.motd);

	const toggleDrawer = (open) => (event) => {
		if (
			event.type === 'keydown' &&
			(event.key === 'Tab' || event.key === 'Shift')
		) {
			return;
		}
		setDrawerOpen(open);
	};

	const onCreate = () => {
		dispatch({
			type: 'SET_STATE',
			payload: { state: STATE_CREATE },
		});
	};

	return (
		<div className={classes.canvas}>
			{Boolean(motd) && <Motd message={motd} />}
			<div className={classes.buttonContainer}>
				<Button variant="contained" onClick={toggleDrawer(true)}>
					<FontAwesomeIcon
						icon={faCircleUser}
						size="lg"
						style={{ marginRight: '8px' }}
					/>
					Select Character
				</Button>
				{characters.length < characterLimit && (
					<Button variant="contained" onClick={onCreate}>
						<FontAwesomeIcon
							icon={faPlus}
							size="lg"
							style={{ marginRight: '8px' }}
						/>
						Create Character
					</Button>
				)}
			</div>

			<Drawer
				anchor="right"
				open={drawerOpen}
				onClose={toggleDrawer(false)}
				classes={{
					paper: classes.drawerPaper,
				}}
			>
				<div className={classes.characterList}>
					{characters.map((char, i) => (
						<div className={classes.characterButtonWrapper} key={i}>
							<CharacterButton id={i} character={char} />
						</div>
					))}
				</div>
				{characters.length > 0 && (
					<div
						className={`${classes.infoIcon} ${classes.infoIconHover}`}
					>
						i
						<div className={classes.tooltip}>
							Right Click to Delete Character
						</div>
					</div>
				)}
			</Drawer>
		</div>
	);
};
