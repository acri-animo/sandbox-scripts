import React, { Fragment, useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useStopwatch } from 'react-use-stopwatch';
import { Grid } from '@mui/material';
import { makeStyles } from '@mui/styles';
import useCountDown from 'react-countdown-hook';
import parseMilliseconds from 'parse-ms';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		margin: '10px',
		position: 'fixed',
		top: 10,
		right: 10,
		zIndex: 1000,
		textAlign: 'right',
		maxWidth: '250px',
		[theme.breakpoints.down('sm')]: {
			maxWidth: '180px',
			margin: '8px',
		},
	},
	appInfo: {
		marginBottom: 8,
		borderBottom: `1px solid rgba(255, 255, 255, 0.3)`,
	},
	appName: {
		color: '#ffffff',
		textTransform: 'uppercase',
		fontFamily: "'Bebas Neue', sans-serif",
		fontSize: 18,
		letterSpacing: '1px',
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		[theme.breakpoints.down('sm')]: {
			fontSize: 16,
		},
	},
	label: {
		fontSize: 16,
		color: '#ffffff',
		fontFamily: "'Orbitron', sans-serif",
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		marginBottom: 4,
		[theme.breakpoints.down('sm')]: {
			fontSize: 14,
		},
	},
	value: {
		fontSize: 16,
		color: '#8685EF',
		fontFamily: "'Orbitron', sans-serif",
		fontWeight: 700,
		whiteSpace: 'nowrap',
		overflow: 'hidden',
		textOverflow: 'ellipsis',
		marginBottom: 4,
		[theme.breakpoints.down('sm')]: {
			fontSize: 14,
		},
	},
	dnfPulse: {
		animation: 'pulse 1s infinite',
		color: '#ff4d4d',
	},
	'@keyframes pulse': {
		'0%': { transform: 'scale(1)' },
		'50%': { transform: 'scale(1.1)' },
		'100%': { transform: 'scale(1)' },
	},
	racerList: {
		marginTop: 8,
		maxHeight: '200px',
		overflowY: 'auto',
	},
	racerItem: {
		display: 'flex',
		justifyContent: 'space-between',
		color: '#ffffff',
		fontFamily: "'Orbitron', sans-serif",
		fontSize: 14,
		marginBottom: 4,
	},
	racerPosition: {
		color: '#8685EF',
		fontWeight: 700,
	},
}));

Number.prototype.pad = function (size) {
	var s = String(this);
	while (s.length < (size || 2)) {
		s = '0' + s;
	}
	return s;
};

export default () => {
	const dispatch = useDispatch();
	const alias = useSelector(
		(state) => state.data.data.player?.Profiles?.redline,
	);
	const trackDetails = useSelector((state) => state.track);
	const classes = useStyles();

	const [lapTime, lapStart, lapStop, lapReset] = useStopwatch();
	const [total, start, stop, reset] = useStopwatch();
	const [dnfTimer, dnfFuncs] = useCountDown(300 * 1000, 10);
	const dnf = parseMilliseconds(dnfTimer);
	const [fastest, setFastest] = useState(null);

	useEffect(() => {
		if (
			trackDetails.show &&
			trackDetails.lap === 1 &&
			trackDetails.checkpoint === 1
		) {
			reset();
			start();
			lapReset();
			lapStart();
			setFastest(null);
		}
	}, [trackDetails.show, trackDetails.lap, trackDetails.checkpoint]);

	useEffect(() => {
		return () => {
			stop();
			lapStop();
			finishLap();
			dispatch({
				type: 'RACE_HUD_END',
			});
		};
	}, []);

	useEffect(() => {
		if (trackDetails.dnf) {
			setTimeout(() => {
				dispatch({
					type: 'RACE_END',
				});
			}, 3000);
		}
	}, [trackDetails.dnf]);

	useEffect(() => {
		if (trackDetails.dnfTime != null) {
			dnfFuncs.start(trackDetails.dnfTime * 1000);
		} else {
			dnfFuncs.pause();
		}
	}, [trackDetails.dnfTime]);

	const finishLap = () => {
		if (lapTime.time > 0) {
			dispatch({
				type: 'ADD_LAP_TIME',
				payload: {
					...lapTime,
					lapStart: trackDetails.lapStart,
					lapEnd: Date.now(),
					alias,
				},
			});
			if (!fastest || lapTime.time < fastest.time) {
				setFastest(lapTime);
			}
		}
	};

	useEffect(() => {
		if (trackDetails.lap > 1) {
			finishLap();
			lapReset();
			lapStart();
		}
	}, [trackDetails.lap]);

	return (
		<Fragment>
			{trackDetails.show ? (
				trackDetails.dnf ? (
					<Grid container className={classes.wrapper}>
						<Grid item xs={12} className={classes.appInfo}>
							<span className={classes.appName}>RACE STATUS</span>
						</Grid>
						<Grid item xs={12} className={classes.label}>
							DNF - Better Luck Next Time!
						</Grid>
					</Grid>
				) : (
					<Grid container className={classes.wrapper}>
						{Boolean(trackDetails.dnfTime) && (
							<Grid item xs={12}>
								<span className={classes.label}>DNF Time</span>
								<div
									className={`${classes.value} ${
										dnfTimer < 10000 ? classes.dnfPulse : ''
									}`}
								>
									{`${dnf.hours.pad(2)}:${dnf.minutes.pad(
										2,
									)}:${dnf.seconds.pad(2)}.${(
										dnf.milliseconds / 10
									).pad(2)}`}
								</div>
							</Grid>
						)}
						{trackDetails.isLaps && (
							<>
								<Grid item xs={12}>
									<span className={classes.label}>Lap</span>
									<div className={classes.value}>
										{trackDetails.lap} /{' '}
										{trackDetails.totalLaps}
									</div>
								</Grid>
								<Grid item xs={12}>
									<span className={classes.label}>
										Current Lap
									</span>
									<div className={classes.value}>
										{lapTime.format}
									</div>
								</Grid>
								<Grid item xs={12}>
									<span className={classes.label}>
										Fastest Lap
									</span>
									<div className={classes.value}>
										{fastest
											? fastest.format
											: '--:--:--.--'}
									</div>
								</Grid>
							</>
						)}
						<Grid item xs={12}>
							<span className={classes.label}>Checkpoint</span>
							<div className={classes.value}>
								{trackDetails.checkpoint} /{' '}
								{trackDetails.totalCheckpoints}
							</div>
						</Grid>
						<Grid item xs={12}>
							<span className={classes.label}>Total Time</span>
							<div className={classes.value}>{total.format}</div>
						</Grid>
					</Grid>
				)
			) : null}
		</Fragment>
	);
};
