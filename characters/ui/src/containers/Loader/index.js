import React from 'react';
import { useSelector } from 'react-redux';
import { Fade, CircularProgress } from '@mui/material';
import { makeStyles, useTheme } from '@mui/styles';
import logo from '../../assets/imgs/mlogo.png';

const useStyles = makeStyles((theme) => ({
	container: {
		height: 'fit-content',
		width: 'fit-content', // Adjusted to fit the circular progress
		position: 'absolute',
		bottom: 0,
		top: 0,
		left: 0,
		right: 0,
		margin: 'auto',
		textAlign: 'center',
	},
	details: {
		position: 'absolute',
		top: '50%',
		left: '50%',
		width: '100%',
		transform: 'translate(-50%, -50%)',
		display: 'flex',
		flexDirection: 'column',
		alignItems: 'center',
		padding: '20px',
	},
	label: {
		color: theme.palette.text.light,
		width: '100%',
		fontSize: 16,
		textShadow: '0 0 5px #000',
		textAlign: 'center',
		padding: 5,
		filter: 'drop-shadow(0 0 5px rgba(25, 118, 210, 0.3))',
	},
	img: {
		maxWidth: 150, // Smaller logo to fit inside the circle
		width: '100%',
		marginBottom: 10,
	},
	progressWrapper: {
		position: 'relative',
		width: 300, // Size of the circular progress
		height: 300, // Match width for a perfect circle
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
	},
}));

function GradientCircularProgress({ size }) {
	const theme = useTheme();

	return (
		<React.Fragment>
			<svg width={0} height={0}>
				<defs>
					<linearGradient
						id="my_gradient"
						x1="0%"
						y1="0%"
						x2="0%"
						y2="100%"
					>
						<stop
							offset="0%"
							stopColor={theme.palette.primary.dark}
						/>
						<stop
							offset="100%"
							stopColor={theme.palette.primary.light}
						/>{' '}
						{/* Gradient variation */}
					</linearGradient>
				</defs>
			</svg>
			<CircularProgress
				sx={{ 'svg circle': { stroke: 'url(#my_gradient)' } }}
				size={size}
				thickness={0.5}
			/>
		</React.Fragment>
	);
}

export default () => {
	const classes = useStyles();
	const loading = useSelector((state) => state.loader.loading);
	const message = useSelector((state) => state.loader.message);

	if (!loading) return null;
	return (
		<Fade in={true} duration={1000}>
			<div className={classes.container}>
				<div className={classes.progressWrapper}>
					<GradientCircularProgress size={300} />{' '}
					{/* Large enough to encircle content */}
					<div className={classes.details}>
						<img className={classes.img} src={logo} alt="logo" />
						{message && (
							<div className={classes.label}>{message}</div>
						)}
					</div>
				</div>
			</div>
		</Fade>
	);
};
