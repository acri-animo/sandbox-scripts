import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { Tab, Tabs } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { throttle } from 'lodash';

import ChopList from './ChopList';
import Reputations from './Reputations';
import { useReputation } from '../../hooks';
import Nui from '../../util/Nui';
import Market from './Market';
import Boosting from './Boosting';
import BoostingMarket from './BoostingMarket';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		height: '100%',
		background: '#121212',
		display: 'flex',
		flexDirection: 'column',
	},
	header: {
		padding: '20px',
		background: '#1E1E1E',
		borderBottom: '1px solid #2A2A2A',
	},

	content: {
		flex: 1,
		display: 'flex',
		flexDirection: 'column',
		overflow: 'hidden',
	},
	tabs: {
		background: '#1E1E1E',
		borderBottom: '1px solid #2A2A2A',
		'& .MuiTabs-indicator': {
			backgroundColor: '#FFFFFF',
		},
	},
	tab: {
		color: '#AAAAAA',
		textTransform: 'none',
		fontSize: '14px',
		minWidth: '120px',
		'&.Mui-selected': {
			color: '#FFFFFF',
		},
	},
	tabContent: {
		flex: 1,
		overflow: 'auto',
		padding: '20px',
		background: '#121212',
	},
	scrollbar: {
		'&::-webkit-scrollbar': {
			width: '6px',
		},
		'&::-webkit-scrollbar-track': {
			background: '#1E1E1E',
		},
		'&::-webkit-scrollbar-thumb': {
			background: '#2A2A2A',
			borderRadius: '3px',
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	const [tab, setTab] = useState(0);
	const [loading, setLoading] = useState(false);
	const [chops, setChops] = useState([]);
	const [reps, setReps] = useState([]);
	const [items, setItems] = useState([]);
	const [banned, setBanned] = useState(null);
	const [canBoost, setCanBoost] = useState(false);

	const fetch = useMemo(
		() =>
			throttle(async () => {
				if (loading) return;
				setLoading(true);
				try {
					const res = await (await Nui.send('GetLSUDetails')).json();
					if (res) {
						setChops(res.chopList);
						setReps(res.reputations);
						setItems(res.items);
						setBanned(res.banned);
						setCanBoost(res.canBoost);
					}
				} catch (err) {
					console.error(err);
				}
				setLoading(false);
			}, 1000),
		[]
	);

	useEffect(() => {
		fetch();
	}, []);

	const handleTabChange = (event, newTab) => {
		setTab(newTab);
	};

	return (
		<div className={classes.wrapper}>
			<div className={classes.content}>
				<Tabs
					value={tab}
					onChange={handleTabChange}
					className={classes.tabs}
					indicatorColor="primary"
					textColor="primary"
				>
					<Tab className={classes.tab} label="Boosting" />
					<Tab className={classes.tab} label="Market" />
					<Tab className={classes.tab} label="Chop Shop" />
					<Tab className={classes.tab} label="Items" />
					<Tab className={classes.tab} label="Reputation" />
				</Tabs>
				<div className={`${classes.tabContent} ${classes.scrollbar}`}>
					{tab === 0 && <Boosting canBoost={canBoost} banned={banned} reputations={reps} />}
					{tab === 1 && <BoostingMarket banned={banned} />}
					{tab === 2 && <ChopList chopList={chops} />}
					{tab === 3 && <Market banned={banned} items={items} />}
					{tab === 4 && <Reputations myReputations={reps} />}
				</div>
			</div>
		</div>
	);
};

