import Nui from '../../util/Nui';

export const initialState = {
	visible: process.env.NODE_ENV != 'production',
	clear: false,
	expanded: true,
	limited: false,
	time: {
		hour: 4,
		minute: 20,
	},
	apps:
		process.env.NODE_ENV == 'production'
			? {}
			: {
					recyclebin: {
						label: 'Recycle Bin',
						name: 'recyclebin',
						icon: ['fas', 'trash-can'],
						color: '#303030',
						hidden: false,
						unread: 0,
						fake: true,
					},
					gangs: {
						label: 'Gangs',
						name: 'gangs', // This must match the folder name exactly
						icon: ['fas', 'cannabis'], // Use an appropriate icon
						color: '#e412ca', // Use a color that matches your theme
						unread: 0,
						hidden: false, // Ensure this is set to false
					},
					heists: {
						label: 'heists',
						name: 'heists', // This must match the folder name exactly
						icon: ['fa', 'anchor'], // Use an appropriate icon
						color: '#00b300', // Use a color that matches your theme
						unread: 0,
						hidden: false, // Ensure this is set to false
					},
					settings: {
						label: 'Settings',
						name: 'settings',
						icon: ['fas', 'gear'],
						color: '#303030',
						hidden: false,
						unread: 0,
					},
					files: {
						label: 'Files',
						name: 'files',
						icon: ['fas', 'folder-open'],
						color: '#D8A71E',
						hidden: false,
						unread: 0,
						fake: true,
					},
					bizwiz: {
						label: 'BizWiz',
						name: 'bizwiz',
						icon: ['fas', 'business-time'],
						color: '#135dd8',
						hidden: false,
						unread: 0,
					},
					teams: {
						label: 'Teams',
						name: 'teams',
						icon: 'people-group',
						color: '#00FF8A',
						unread: 0,
					},
					terminal: {
						label: 'Terminal',
						name: 'terminal',
						icon: ['fas', 'terminal'],
						color: '#000000',
						hidden: false,
						size: {
							width: 600,
							height: 400,
						},
						unread: 0,
					},
					supplymate: {
						label: 'Supply Mate',
						name: 'supplymate',
						icon: 'parachute-box',
						color: '#9808c7',
						unread: 0,
						restricted: {
							state: 'PHONE_VPN',
						},
					},
					lsunderground: {
						label: 'Underground',
						name: 'lsunderground',
						icon: 'user-secret',
						color: '#E95200',
						unread: 0,
						restricted: {
							state: 'ACCESS_LSUNDERGROUND',
						},
					},
					redline: {
						label: 'Redline',
						name: 'redline',
						icon: ['fas', 'car'],
						color: '#9d1614',
						hidden: false,
						unread: 0,
					},
			  },
};

const appReducer = (state = initialState, action) => {
	switch (action.type) {
		case 'LOAD_PERMS':
			return {
				...state,
				permissions: action.payload,
			};
		case 'LAPTOP_VISIBLE':
			return {
				...state,
				visible: true,
			};
		case 'LAPTOP_NOT_VISIBLE':
			Nui.send('CloseLaptop', null);
			return {
				...state,
				visible: false,
				limited: false,
			};
		case 'LAPTOP_NOT_VISIBLE_FORCED':
			return {
				...state,
				visible: false,
				limited: false,
			};
		case 'LAPTOP_VISIBLE_LIMITED':
			return {
				...state,
				visible: true,
				limited: true,
			};
		case 'CLEAR_HISTORY':
			return {
				...state,
				clear: true,
			};
		case 'TOGGLE_EXPANDED':
			Nui.send('UpdateSetting', {
				type: 'Expanded',
				val: !state.expanded,
			});
			return {
				...state,
				expanded: !state.expanded,
			};
		case 'SET_EXPANDED':
			return {
				...state,
				expanded: action.payload.expanded,
			};
		case 'CLEARED_HISTORY':
			Nui.send('CDExpired');
			return {
				...state,
				clear: false,
			};
		case 'SET_APPS':
			return {
				...state,
				apps: action.payload,
			};
		case 'REORDER_APP':
			let home = state.player?.Apps?.home.filter(
				(app) => app !== action.payload.app,
			);
			home.splice(action.payload.index, 0, action.payload.app);
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						home: home,
					},
				},
			};
		case 'REORDER_APP_DOCK':
			let dock = state.player?.Apps?.dock.filter(
				(app) => app !== action.payload.app,
			);
			dock.splice(action.payload.index, 0, action.payload.app);
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						dock: dock,
					},
				},
			};
		case 'ADD_UNREAD':
			return {
				...state,
				apps: apps.map((app) => {
					if (app.name == action.payload.name)
						return {
							...app,
							unread: app.unread + action.payload.count,
						};
					else return app;
				}),
			};
		case 'ADD_TO_HOME':
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						home: [...state.player?.Apps?.home, action.payload.app],
					},
				},
			};
		case 'REMOVE_FROM_HOME':
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						home: state.player?.Apps?.home.filter(
							(app) => app != action.payload.app,
						),
					},
				},
			};
		case 'DOCK_APP':
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						dock: [...state.player?.Apps?.dock, action.payload.app],
					},
				},
			};
		case 'UNDOCK_APP':
			return {
				...state,
				player: {
					...state.player,
					Apps: {
						...state.player.Apps,
						dock: state.player?.Apps?.dock.filter(
							(app) => app != action.payload.app,
						),
					},
				},
			};
		case 'SET_TIME':
			return {
				...state,
				time: action.payload,
			};
		default:
			return state;
	}
};

export default appReducer;
