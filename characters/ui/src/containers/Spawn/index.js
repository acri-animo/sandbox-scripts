import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Button, Typography, Divider } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowLeft, faPlane } from '@fortawesome/free-solid-svg-icons';
import { makeStyles } from '@mui/styles';

import Nui from '../../util/Nui';
import { Motd } from '../../components';
import mlogo from '../../assets/imgs/mlogo.png';

import SpawnButton from './components/SpawnButton';
import { STATE_CHARACTERS } from '../../util/States';
import { PlayCharacter } from '../../util/NuiEvents';

const useStyles = makeStyles((theme) => ({
	canvas: {
		height: '100vh',
		width: '100vw',
		position: 'relative',
	},
	logo: {
		width: 150,
		position: 'absolute',
		top: 20,
		right: 20,
	},
	motd: {
		position: 'absolute',
		top: 20,
		left: 20,
		textAlign: 'left',
		maxWidth: '400px',
		padding: '10px',
		background: 'rgba(0, 0, 0, 0.5)',
		color: '#fff',
		borderRadius: '8px',
		zIndex: 2,
	},
	centeredContent: {
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		justifyContent: 'center',
		left: '25%',
		height: '100%',
		width: '100%',
		position: 'absolute',
	},
	backgroundBox: {
		width: '400px',
		height: 'auto',
		padding: '20px',
		background: `${theme.palette.secondary.dark}90`,
		borderRadius: '16px',
		zIndex: 0,
		boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)',
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		gap: '20px',
		position: 'relative', // Enable relative positioning for the icon
	},
	iconContainer: {
		position: 'absolute',
		top: '-20px', // Adjust overlap
		right: '-20px', // Adjust overlap
		width: '60px',
		height: '60px',
		background: theme.palette.secondary.dark,
		border: `4px solid ${'#fff'}`,
		borderRadius: '50%',
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'center',
		boxShadow: '0 4px 8px rgba(0, 0, 0, 0.5)',
		zIndex: 2, // Place above the box
	},
	icon: {
		color: '#fff',
		fontSize: '24px',
	},
	spawnContainer: {
		display: 'flex',
		flexDirection: 'column',
		gap: '5px',
		width: '380px',
		maxHeight: '200px',
		overflowY: 'auto',
		overflowX: 'hidden',
		'&::-webkit-scrollbar': {
			display: 'none',
		},
		'&::-webkit-scrollbar-thumb': {
			background: theme.palette.border.divider,
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: theme.palette.border.input,
		},
	},
	charInfo: {
		width: '100%',
		textAlign: 'left',
		color: '#fff',
	},
	highlight: {
		color: theme.palette.primary.light,
		fontWeight: 'bold',
	},
	buttonGroup: {
		display: 'flex',
		gap: '10px',
		justifyContent: 'center',
		width: '100%',
	},
	divider: {
		width: '100%',
		backgroundColor: theme.palette.divider,
		margin: '10px 0',
	},
	button: {
		borderRadius: '50px',
		padding: '10px 20px',
		color: '#fff',
		transition: 'background-color 0.3s ease',
	},
	backButton: {
		backgroundColor: theme.palette.secondary.main,
		boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)',
		'&:hover': {
			backgroundColor: theme.palette.secondary.light,
		},
	},
	playButton: {
		backgroundColor: theme.palette.success.main,
		boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)',
		'&:hover': {
			backgroundColor: theme.palette.success.dark,
		},
	},
}));

export default () => {
	const classes = useStyles();
	const dispatch = useDispatch();

	const motd = useSelector((state) => state.characters.motd);
	const spawns = useSelector((state) => state.spawn.spawns);
	const selected = useSelector((state) => state.spawn.selected);
	const selectedChar = useSelector((state) => state.characters.selected);

	const onSpawn = () => {
		Nui.send(PlayCharacter, {
			spawn: selected,
			character: selectedChar,
		});
		dispatch({ type: 'LOADING_SHOW', payload: { message: 'Spawning' } });
		dispatch({ type: 'UPDATE_PLAYED' });
		dispatch({ type: 'DESELECT_CHARACTER' });
		dispatch({ type: 'DESELECT_SPAWN' });
	};

	const goBack = () => {
		dispatch({ type: 'DESELECT_CHARACTER' });
		dispatch({ type: 'DESELECT_SPAWN' });
		dispatch({ type: 'SET_STATE', payload: { state: STATE_CHARACTERS } });
	};

	return (
		<div className={classes.canvas}>
			{motd && <Motd message={motd} className={classes.motd} />}
			<img className={classes.logo} src={mlogo} />
			<div className={classes.centeredContent}>
				<div className={classes.backgroundBox}>
					<div className={classes.iconContainer}>
						<FontAwesomeIcon
							icon={faPlane}
							className={classes.icon}
						/>
					</div>
					<Typography variant="h4">SELECT SPAWN</Typography>
					<div className={classes.spawnContainer}>
						{spawns.map((spawn, i) => (
							<SpawnButton
								key={i}
								spawn={spawn}
								onPlay={onSpawn}
							/>
						))}
					</div>
					<Divider className={classes.divider} />
					<div className={classes.charInfo}>
						<Typography variant="h6">CHARACTER:</Typography>
						<Typography
							variant="body1"
							className={selected ? classes.highlight : ''}
						>
							{selectedChar?.First} {selectedChar?.Last}
						</Typography>
						<Typography variant="h6">SPAWN LOCATION:</Typography>
						<Typography
							variant="body1"
							className={selected ? classes.highlight : ''}
						>
							{selected ? selected.label : '(No Spawn Selected)'}
						</Typography>
					</div>
					<div className={classes.buttonGroup}>
						<Button
							onClick={goBack}
							className={`${classes.button} ${classes.backButton}`}
						>
							<FontAwesomeIcon icon={faArrowLeft} />
						</Button>
						{selected && (
							<Button
								onClick={onSpawn}
								className={`${classes.button} ${classes.playButton}`}
							>
								<FontAwesomeIcon icon={faPlane} />
							</Button>
						)}
					</div>
				</div>
			</div>
		</div>
	);
};
