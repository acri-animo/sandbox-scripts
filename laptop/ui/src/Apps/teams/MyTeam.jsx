import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles, withStyles } from '@mui/styles';
import {
	Grid,
	Button,
	List,
	ListItem,
	ListItemText,
	ListItemSecondaryAction,
	IconButton,
	TextField,
	Paper,
	Typography,
	Box,
	Avatar,
	Chip,
} from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Modal } from '../../components';
import { throttle } from 'lodash';

import NumberFormat from 'react-number-format';
import Nui from '../../util/Nui';
import { useAlert } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	heading: {
		color: '#ffffff',
		fontSize: 20,
		fontWeight: 'bold',
		marginBottom: 15,
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	actionBtn: {
		fontSize: 18,
		color: '#ffffff',
		'&:hover': {
			backgroundColor: 'rgba(255, 255, 255, 0.1)',
		},
		'&.Mui-disabled': {
			color: 'rgba(255, 255, 255, 0.3)',
		},
	},
	editorField: {
		marginBottom: 15,
		'& .MuiOutlinedInput-root': {
			'& fieldset': {
				borderColor: 'rgba(255, 255, 255, 0.1)',
			},
			'&:hover fieldset': {
				borderColor: 'rgba(255, 255, 255, 0.2)',
			},
			'&.Mui-focused fieldset': {
				borderColor: '#ffffff',
			},
		},
		'& .MuiInputLabel-root': {
			color: 'rgba(255, 255, 255, 0.7)',
		},
		'& .MuiInputLabel-root.Mui-focused': {
			color: '#ffffff',
		},
	},
	bold: {
		'& span': {
			fontWeight: 700,
		}
	},
	teamCard: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 12,
		padding: 20,
		marginBottom: 15,
		boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
	},
	teamName: {
		color: '#ffffff',
		fontSize: 20,
		fontWeight: 'bold',
		marginBottom: 10,
		display: 'flex',
		alignItems: 'center',
		justifyContent: 'space-between',
	},
	teamInfo: {
		color: 'rgba(255, 255, 255, 0.7)',
		fontSize: 14,
		marginBottom: 5,
		display: 'flex',
		alignItems: 'center',
		gap: 8,
	},
	teamStatus: {
		display: 'inline-flex',
		alignItems: 'center',
		padding: '4px 12px',
		borderRadius: 6,
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		fontSize: 12,
		marginBottom: 15,
		gap: 6,
	},
	memberList: {
		marginTop: 20,
	},
	memberItem: {
		background: 'rgba(255, 255, 255, 0.03)',
		borderRadius: 8,
		marginBottom: 10,
		padding: '12px 15px',
		'&:hover': {
			background: 'rgba(255, 255, 255, 0.05)',
		},
	},
	leaderBadge: {
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		fontSize: 12,
		padding: '2px 8px',
		borderRadius: 4,
		marginLeft: 8,
	},
	actionButton: {
		backgroundColor: 'rgba(255, 255, 255, 0.1)',
		color: '#ffffff',
		padding: '8px 16px',
		borderRadius: 6,
		'&:hover': {
			backgroundColor: 'rgba(255, 255, 255, 0.2)',
		},
		'&.Mui-disabled': {
			backgroundColor: 'rgba(255, 255, 255, 0.05)',
			color: 'rgba(255, 255, 255, 0.3)',
		},
	},
	emptyState: {
		textAlign: 'center',
		padding: 30,
	},
	emptyTitle: {
		fontSize: 18,
		fontWeight: 'bold',
		color: 'rgba(255, 255, 255, 0.7)',
		marginBottom: 10,
	},
	emptySubtitle: {
		fontSize: 14,
		color: 'rgba(255, 255, 255, 0.5)',
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const alert = useAlert();

	const myData = useSelector((state) => state.data.data.player);
	const myGroup = useSelector((state) => state.data.data.myGroup);
	const myGroupLeader = myGroup?.Members?.find(m => m.Leader);

	const [creatingGroup, setCreatingGroup] = useState(null);
	const [invitingMember, setInvitingMember] = useState(null);
	const [removingMember, setRemovingMember] = useState(null);
	const [deleting, setDeleting] = useState(false);

	const onStartCreatingGroup = () => {
		setCreatingGroup({
			Name: "",
		});
	}

	const onCreateGroup = async (e) => {
		e.preventDefault();

		try {
			const res = await (await Nui.send("CreateTeam", creatingGroup)).json();

			if (res?.success) {
				alert('Team Created');
			} else {
				if (res?.message) {
					alert('Team Name Already Taken');
				} else {
					alert('Failed to Create Team');
				}
			}
		} catch (e) {
			console.log(e)
		}

		setCreatingGroup(null);
	};

	const onStartInvitingMember = () => {
		setInvitingMember({
			SID: "",
		});
	};

	const onInviteMember = async (e) => {
		e.preventDefault();

		try {
			const res = await (await Nui.send("InviteTeamMember", {
				SID: parseInt(invitingMember?.SID) ?? 0
			})).json();

			if (res?.success) {
				alert('Member Invited');
			} else {
				alert('Member Invite Failed');
			}
		} catch (e) {
			console.log(e)
		}

		setInvitingMember(null);
	};

	const onStartRemovingMember = (member) => {
		setRemovingMember(member);
	};

	const onRemovingMember = async (e) => {
		e.preventDefault();

		try {
			const res = await (await Nui.send("RemoveTeamMember", removingMember)).json();

			if (res) {
				alert('Member Removed');
			} else {
				alert('Member Removal Failed');
			}
		} catch (e) {
			console.log(e)
		}

		setRemovingMember(null);
	};

	const onStartDeleting = () => {
		setDeleting(true);
	};

	const onDelete = async (e) => {
		e.preventDefault();

		try {
			const res = await (await Nui.send("DeleteTeam")).json();

			if (res) {
				alert('Team Deleted');
			} else {
				alert('Failed to Delete Team');
			}
		} catch (e) {
			console.log(e)
		}

		setDeleting(false);
	};

	return (
		<>
			<Typography className={classes.heading}>My Team</Typography>
			{(!Boolean(myGroup) || !Boolean(myGroupLeader)) ? (
				<Button
					className={classes.actionButton}
					variant="contained"
					onClick={onStartCreatingGroup}
					startIcon={<FontAwesomeIcon icon={['fas', 'plus']} />}
				>
					Create Team
				</Button>
			) : (
				<Paper className={classes.teamCard} elevation={0}>
					<Box display="flex" justifyContent="space-between" alignItems="center">
						<Typography className={classes.teamName}>{myGroup.Name}</Typography>
						{myGroupLeader.SID == myData.SID && (
							<IconButton
								className={classes.actionBtn}
								onClick={onStartDeleting}
								disabled={myGroup.State !== 0}
							>
								<FontAwesomeIcon icon={['fas', 'trash']} />
							</IconButton>
						)}
					</Box>
					<Chip
						label={myGroup.StateName}
						className={classes.teamStatus}
						size="small"
					/>
					<Typography className={classes.teamInfo}>
						Team Leader: {myGroupLeader?.First} {myGroupLeader?.Last} ({myGroupLeader?.SID})
					</Typography>
					<Typography className={classes.teamInfo}>
						Members: {myGroup.Members.length}/5
					</Typography>
					<List className={classes.memberList}>
						{myGroup.Members.filter(m => !m.Leader).map((member) => (
							<ListItem
								key={`member-${member?.SID}`}
								className={classes.memberItem}
							>
								<ListItemText
									className={myData.SID == member?.SID ? classes.bold : null}
									primary={`${member?.First} ${member?.Last} (${member?.SID})`}
								/>
								{(myGroupLeader.SID == myData.SID || myData.SID == member.SID) && (
									<ListItemSecondaryAction>
										<IconButton
											edge="end"
											color="error"
											className={classes.actionBtn}
											onClick={() => onStartRemovingMember(member)}
										>
											<FontAwesomeIcon icon={['fas', 'user-minus']} />
										</IconButton>
									</ListItemSecondaryAction>
								)}
							</ListItem>
						))}
					</List>
					{myGroupLeader.SID == myData.SID && myGroup.Members.length < 5 && (
						<Button
							className={classes.actionButton}
							variant="contained"
							onClick={onStartInvitingMember}
							disabled={myGroup.State !== 0}
							startIcon={<FontAwesomeIcon icon={['fas', 'user-plus']} />}
							fullWidth
						>
							Invite Member
						</Button>
					)}
				</Paper>
			)}

			<Modal
				open={Boolean(creatingGroup)}
				title="Create Team"
				closeLang="Cancel"
				maxWidth="md"
				submitLang="Create"
				onSubmit={onCreateGroup}
				onClose={() => setCreatingGroup(null)}
			>
				<TextField
					fullWidth
					required
					label="Team Name"
					name="Name"
					className={classes.editorField}
					value={creatingGroup?.Name}
					onChange={(e) => setCreatingGroup({ ...creatingGroup, Name: e.target.value })}
				/>
			</Modal>

			<Modal
				open={Boolean(invitingMember)}
				title="Invite Member"
				closeLang="Cancel"
				maxWidth="md"
				submitLang="Invite"
				onSubmit={onInviteMember}
				onClose={() => setInvitingMember(null)}
			>
				<NumberFormat
					fullWidth
					required
					label="State ID"
					name="SID"
					className={classes.editorField}
					value={invitingMember?.SID}
					onChange={(e) => setInvitingMember({ ...invitingMember, SID: e.target.value })}
					type="tel"
					isNumericString
					customInput={TextField}
				/>
			</Modal>

			<Modal
				open={Boolean(removingMember)}
				title="Remove Member"
				closeLang="Cancel"
				maxWidth="md"
				submitLang="Remove"
				onSubmit={onRemovingMember}
				onClose={() => setRemovingMember(null)}
			>
				<p>Are you sure you want to remove {removingMember?.First} {removingMember?.Last} from the team?</p>
			</Modal>

			<Modal
				open={deleting}
				title="Delete Team"
				closeLang="Cancel"
				maxWidth="md"
				submitLang="Delete"
				onSubmit={onDelete}
				onClose={() => setDeleting(false)}
			>
				<p>Are you sure you want to delete the team? This action cannot be undone.</p>
			</Modal>
		</>
	);
};
