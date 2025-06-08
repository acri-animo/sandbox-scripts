/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import Moment from 'react-moment';
import {
	Fade,
	Dialog,
	DialogActions,
	DialogContent,
	DialogContentText,
	DialogTitle,
	Button,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import Tilt from 'react-parallax-tilt';
import Nui from '../../../util/Nui';
import { SelectCharacter, DeleteCharacter } from '../../../util/NuiEvents';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
	faBriefcase,
	faClock,
	faIdCard,
} from '@fortawesome/free-solid-svg-icons';

const useStyles = makeStyles((theme) => ({
	container: {
		width: 300,
		height: 150,
		padding: 15,
		display: 'flex',
		flexDirection: 'row',
		alignItems: 'center',
		background: `${theme.palette.secondary.main}70`,
		borderRadius: 8,
		cursor: 'pointer',
		userSelect: 'none',
	},
	stateId: {
		width: 40,
		height: 40,
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		fontSize: 20,
		fontWeight: 'bold',
		color: 'white',
		borderRadius: '20%',
		border: `2px solid ${theme.palette.text.primary}`,
		marginRight: 15,
	},
	details: {
		display: 'flex',
		flexDirection: 'column',
		gap: 4,
	},
	detailRow: {
		display: 'flex',
		alignItems: 'center',
		fontSize: 14,
		gap: 10,
	},
	divider: {
		border: 0,
		height: 1,
		background: theme.palette.divider,
		width: '100%',
		margin: '4px 0',
	},
	name: {
		fontSize: 18,
		fontWeight: 'bold',
		marginBottom: -4,
		color: theme.palette.text.primary,
	},
	played: {
		fontSize: 12,
		color: theme.palette.text.disabled,
		display: 'flex',
		alignItems: 'center',
	},
	icon: {
		fontSize: 16,
		color: theme.palette.text.secondary,
	},
	dialog: {
		textAlign: 'center',
	},
}));

export default ({ character }) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const selected = useSelector((state) => state.characters.selected);

	const [open, setOpen] = useState(false);

	const onClick = () => {
		dispatch({
			type: 'LOADING_SHOW',
			payload: { message: 'Getting Spawn Points' },
		});
		dispatch({
			type: 'SELECT_CHARACTER',
			payload: {
				character: character,
			},
		});
		Nui.send(SelectCharacter, { id: character.ID });
	};

	const onRightClick = (e) => {
		e.preventDefault();
		setOpen(true);
	};

	const onDelete = () => {
		dispatch({
			type: 'LOADING_SHOW',
			payload: { message: 'Deleting Character' },
		});
		Nui.send(DeleteCharacter, { id: character.ID });
	};

	return (
		<Fade in={true}>
			<div>
				<Tilt
					glareEnable
					glareBorderRadius="8px"
					glareColor="#8685EF"
					tiltMaxAngleX={10}
					tiltMaxAngleY={10}
				>
					<div
						className={`${classes.container} ${
							selected?.ID === character?.ID ? 'active' : ''
						}`}
						onClick={onClick}
						onContextMenu={onRightClick}
					>
						<div className={classes.details}>
							<div
								className={`${classes.detailRow} ${classes.name}`}
							>
								{character.First} {character.Last}
							</div>
							<hr className={classes.divider} />
							<div className={classes.details}>
								<div
									className={`${classes.detailRow} ${classes.stateIdRow}`}
								>
									<FontAwesomeIcon
										icon={faIdCard}
										className={classes.icon}
									/>
									<span>{character.SID}</span>
								</div>
								<div
									className={`${classes.detailRow} ${classes.job}`}
								>
									<FontAwesomeIcon
										icon={faBriefcase}
										className={classes.icon}
									/>
									{!Boolean(character?.Jobs) ||
									character?.Jobs?.length === 0 ? (
										<span>Unemployed</span>
									) : character?.Jobs?.length === 1 ? (
										<span>
											{character?.Jobs[0].Workplace
												? `${character?.Jobs[0].Workplace.Name} - ${character?.Jobs[0].Grade.Name}`
												: `${character?.Jobs[0].Name} - ${character?.Jobs[0].Grade.Name}`}
										</span>
									) : (
										<span>
											{character?.Jobs?.length} Jobs
										</span>
									)}
								</div>
								<div
									className={`${classes.detailRow} ${classes.played}`}
								>
									<FontAwesomeIcon
										icon={faClock}
										className={classes.icon}
									/>
									<span>
										Last Played:{' '}
										{+character.LastPlayed === -1 ? (
											<span>Never</span>
										) : (
											<Moment
												date={+character.LastPlayed}
												format="M/D/YYYY h:mm:ss A"
												withTitle
											/>
										)}
									</span>
								</div>
							</div>
						</div>
					</div>
				</Tilt>
				<Dialog
					open={open}
					onClose={() => setOpen(false)}
					classes={{ paper: classes.dialog }}
				>
					<DialogTitle>{`Delete ${character.First} ${character.Last}?`}</DialogTitle>
					<DialogContent>
						<DialogContentText>
							Are you sure you want to delete {character.First}{' '}
							{character.Last}? This action is completely &
							entirely irreversible by{' '}
							<i>
								<b>anyone</b>
							</i>
							, including staff. Proceed?
						</DialogContentText>
					</DialogContent>
					<DialogActions>
						<Button onClick={() => setOpen(false)} color="inherit">
							No
						</Button>
						<Button onClick={onDelete} color="primary" autoFocus>
							Yes
						</Button>
					</DialogActions>
				</Dialog>
			</div>
		</Fade>
	);
};
