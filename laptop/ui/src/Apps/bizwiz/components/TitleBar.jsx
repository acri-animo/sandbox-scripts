import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { Box } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		display: 'flex',
		alignItems: 'center',
		width: '100%',
		gap: theme.spacing(2),
	},
	logo: {
		width: 40,
		height: 40,
		objectFit: 'contain',
		borderRadius: theme.spacing(1),
		background: 'rgba(255, 255, 255, 0.05)',
		padding: theme.spacing(1),
	},
	branding: {
		display: 'flex',
		flexDirection: 'column',
		gap: theme.spacing(0.5),
	},
	title: {
		fontSize: 16,
		fontWeight: 600,
		color: '#fff',
	},
	subtitle: {
		fontSize: 12,
		color: 'rgba(255, 255, 255, 0.5)',
	},
}));

export default ({ items }) => {
	const classes = useStyles();
	const dispatch = useDispatch();

	const logo = useSelector((state) => state.data.data.businessLogo);
    const onDuty = useSelector((state) => state.data.data.onDuty);
	const jobs = useSelector((state) => state.data.data.player.Jobs);
    const jobData = jobs?.find(j => j.Id == onDuty);

	return (
		<Box className={classes.wrapper}>
			<img src={logo} className={classes.logo} alt="Business Logo" />
			<div className={classes.branding}>
				<div className={classes.title}>{jobData?.Name}</div>
				<div className={classes.subtitle}>{jobData?.Grade?.Name}</div>
			</div>
		</Box>
	);
};
