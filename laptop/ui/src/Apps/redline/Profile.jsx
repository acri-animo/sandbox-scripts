import React, { Fragment, useState, useEffect } from 'react';
import Nui from '../../util/Nui';
import { makeStyles } from '@mui/styles';
import {
	Avatar,
	Box,
	Grid,
	IconButton,
	Typography,
	Card,
	TextField,
	CircularProgress,
} from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useAlert } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		background: '#16213e',
		overflowY: 'auto',
		padding: 16,
		'&::-webkit-scrollbar': {
			width: 6,
		},
		'&::-webkit-scrollbar-thumb': {
			background: 'rgba(134, 133, 239, 0.4)',
			borderRadius: '3px',
		},
		'&::-webkit-scrollbar-thumb:hover': {
			background: '#8685EF',
		},
		'&::-webkit-scrollbar-track': {
			background: 'transparent',
		},
	},
	content: {
		height: '87%',
		width: '100%',
	},
	card: {
		padding: 24,
		width: '100%',
		background: 'rgba(134, 133, 239, 0.15)',
		border: '1px solid rgba(134, 133, 239, 0.2)',
		borderRadius: '16px',
		transition: 'all 0.2s ease',
		'&:hover': {
			background: 'rgba(134, 133, 239, 0.2)',
		},
	},
	avatar: {
		width: 120,
		height: 120,
		marginBottom: 16,
		margin: 'auto',
		border: '3px solid #8685EF',
		borderRadius: '8px',
		boxShadow: '0 4px 12px rgba(134, 133, 239, 0.3)',
	},
	statIcon: {
		marginBottom: 8,
		filter: 'drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3))',
	},
	textInput: {
		marginBottom: 16,
		marginTop: 16,
		'& .MuiOutlinedInput-root': {
			borderRadius: '8px',
			backgroundColor: 'rgba(255, 255, 255, 0.05)',
			'& fieldset': {
				borderColor: 'rgba(134, 133, 239, 0.3)',
				transition: 'border-color 0.2s ease',
			},
			'&:hover fieldset': {
				borderColor: 'rgba(134, 133, 239, 0.5)',
			},
			'&.Mui-focused fieldset': {
				borderColor: '#8685EF',
				boxShadow: '0 0 0 1px rgba(134, 133, 239, 0.2)',
			},
		},
		'& .MuiInputLabel-root': {
			color: 'rgba(255, 255, 255, 0.7)',
			'&.Mui-focused': {
				color: '#8685EF',
			},
		},
		'& .MuiInputBase-input': {
			color: 'white',
		},
	},
	actionButton: {
		width: '48px',
		height: '48px',
		borderRadius: '12px',
		backgroundColor: 'rgba(134, 133, 239, 0.2)',
		border: '1px solid rgba(134, 133, 239, 0.3)',
		color: 'white',
		transition: 'all 0.2s ease',
		'&:hover': {
			backgroundColor: 'rgba(134, 133, 239, 0.3)',
			transform: 'scale(1.05)',
		},
		'&:focus': {
			outline: 'none',
			boxShadow: '0 0 0 2px rgba(134, 133, 239, 0.5)',
		},
		'&.save': {
			backgroundColor: '#8685EF',
			'&:hover': {
				backgroundColor: '#7674e8',
			},
		},
		'&.close': {
			backgroundColor: 'rgba(255, 107, 107, 0.2)',
			border: '1px solid rgba(255, 107, 107, 0.3)',
			color: '#ff6b6b',
			'&:hover': {
				backgroundColor: 'rgba(255, 107, 107, 0.3)',
			},
		},
	},
	profileHeader: {
		color: 'white',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		fontWeight: '600',
		marginBottom: '8px',
	},
	profileBio: {
		color: 'rgba(255, 255, 255, 0.8)',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		lineHeight: 1.5,
	},
	statsTitle: {
		color: '#8685EF',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		fontWeight: '600',
		marginBottom: '16px',
	},
	statLabel: {
		color: 'rgba(255, 255, 255, 0.7)',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		fontSize: '14px',
		marginBottom: '4px',
	},
	statValue: {
		color: 'white',
		fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
		fontSize: '24px',
		fontWeight: '600',
	},
	loadingContainer: {
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		height: '200px',
	},
	loadingSpinner: {
		color: '#8685EF',
	},
}));

export default ({ alias, racerSID, onClose, onViewRace }) => {
	const classes = useStyles();
	const showAlert = useAlert();

	const [loading, setLoading] = useState(true);
	const [isEditing, setIsEditing] = useState(false);
	const [racerData, setRacerData] = useState(null);
	const [tempPicture, setTempPicture] = useState('');
	const [tempBio, setTempBio] = useState('');

	const mockData = {
		totalFirst: 5,
		totalSecond: 3,
		totalThird: 2,
		totalRaces: 15,
		favoriteVehicle: 'Sultan RS',
		picture: 'Image URL',
		bio: 'This is a mock bio.',
	};

	useEffect(() => {
		const fetchRacerStats = async () => {
			try {
				const res = await (
					await Nui.send('GetRacerProfile', { sid: racerSID })
				).json();
				setRacerData(res);
				setTempPicture(res.picture);
				setTempBio(res.bio);
				setLoading(false);
			} catch (error) {
				console.error('Error fetching racer stats:', error);
				setRacerData(mockData);
				setTempPicture(mockData.picture);
				setTempBio(mockData.bio);
				setLoading(false);
			}
		};

		if (alias) {
			fetchRacerStats();
		} else {
			setRacerData(mockData);
			setTempPicture(mockData.picture);
			setTempBio(mockData.bio);
			setLoading(false);
		}
	}, [alias]);

	const handleEditToggle = () => {
		if (isEditing) {
			setRacerData((prevData) => ({
				...prevData,
				picture: tempPicture,
				bio: tempBio,
			}));

			Nui.send('UpdateRacerProfile', {
				sid: racerSID,
				picture: tempPicture,
				bio: tempBio,
			});

			showAlert('Profile updated!');
		}
		setIsEditing(!isEditing);
	};

	return (
		<div className={classes.wrapper}>
			<div className={classes.content}>
				<Fragment>
					<IconButton
						className={`${classes.actionButton} ${
							isEditing ? 'save' : ''
						}`}
						onClick={handleEditToggle}
						sx={{ position: 'absolute', top: 50, right: 110 }}
					>
						<FontAwesomeIcon
							icon={
								isEditing
									? ['fas', 'save']
									: ['fas', 'pencil-alt']
							}
						/>
					</IconButton>
					<IconButton
						className={`${classes.actionButton} close`}
						onClick={onClose}
						sx={{ position: 'absolute', top: 50, right: 50 }}
					>
						<FontAwesomeIcon icon={['fas', 'times']} />
					</IconButton>
				</Fragment>
				<Box sx={{ padding: 3 }}>
					<Box sx={{ textAlign: 'center', mb: 4 }}>
						<Avatar
							src={
								racerData?.picture ||
								'/path/to/default/avatar.png'
							}
							alt="Racing Avatar"
							className={classes.avatar}
							variant="square"
						/>
						<Typography
							variant="h5"
							className={classes.profileHeader}
						>
							{alias || 'Unknown Racer'}
						</Typography>
						{isEditing ? (
							<>
								<TextField
									label="Profile Picture URL"
									value={tempPicture}
									onChange={(e) =>
										setTempPicture(e.target.value)
									}
									fullWidth
									variant="outlined"
									className={classes.textInput}
								/>
								<TextField
									label="Bio"
									value={tempBio}
									onChange={(e) => setTempBio(e.target.value)}
									fullWidth
									multiline
									rows={3}
									variant="outlined"
									className={classes.textInput}
								/>
							</>
						) : (
							<Typography
								className={classes.profileBio}
								sx={{ mt: 1 }}
							>
								{racerData?.bio}
							</Typography>
						)}
					</Box>

					{loading ? (
						<Box className={classes.loadingContainer}>
							<CircularProgress
								className={classes.loadingSpinner}
								size={60}
							/>
						</Box>
					) : (
						<Grid container direction="column" alignItems="center">
							<Grid item xs={12} md={8}>
								<Card elevation={0} className={classes.card}>
									<Typography
										className={classes.statsTitle}
										variant="h6"
										gutterBottom
									>
										Racing Stats
									</Typography>
									<Grid container spacing={3}>
										<Grid item xs={12}>
											<Typography
												className={classes.statLabel}
											>
												Total Races:
											</Typography>
											<Typography
												className={classes.statValue}
											>
												{racerData?.totalRaces || 0}
											</Typography>
										</Grid>

										<Grid item xs={12}>
											<Typography
												className={classes.statLabel}
												sx={{ mb: 2 }}
											>
												Placements:
											</Typography>
										</Grid>
										<Grid
											container
											item
											xs={12}
											justifyContent="space-between"
										>
											<Grid
												item
												xs={4}
												sx={{ textAlign: 'center' }}
											>
												<FontAwesomeIcon
													icon={['fas', 'award']}
													size="2x"
													color="#FFD700"
													className={classes.statIcon}
												/>
												<Typography
													className={
														classes.statValue
													}
												>
													{racerData?.totalFirst || 0}
												</Typography>
											</Grid>
											<Grid
												item
												xs={4}
												sx={{ textAlign: 'center' }}
											>
												<FontAwesomeIcon
													icon={['fas', 'medal']}
													size="2x"
													color="#C0C0C0"
													className={classes.statIcon}
												/>
												<Typography
													className={
														classes.statValue
													}
												>
													{racerData?.totalSecond ||
														0}
												</Typography>
											</Grid>
											<Grid
												item
												xs={4}
												sx={{ textAlign: 'center' }}
											>
												<FontAwesomeIcon
													icon={['fas', 'trophy']}
													size="2x"
													color="#CD7F32"
													className={classes.statIcon}
												/>
												<Typography
													className={
														classes.statValue
													}
												>
													{racerData?.totalThird || 0}
												</Typography>
											</Grid>
										</Grid>

										<Grid item xs={12} sx={{ mt: 2 }}>
											<Typography
												className={classes.statLabel}
											>
												Favorite Vehicle:
											</Typography>
											<Typography
												className={classes.statValue}
											>
												{racerData?.favoriteVehicle ||
													'None'}
											</Typography>
										</Grid>
									</Grid>
								</Card>
							</Grid>
						</Grid>
					)}
				</Box>
			</div>
		</div>
	);
};
