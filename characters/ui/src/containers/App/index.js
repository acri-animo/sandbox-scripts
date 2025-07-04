import '@babel/polyfill';
import React from 'react';
import { useSelector } from 'react-redux';
import {
	CssBaseline,
	ThemeProvider,
	createTheme,
	StyledEngineProvider,
} from '@mui/material';
import { MantineProvider } from '@mantine/core';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';

import Loader from '../Loader';
import Splash from '../Splash';
import Characters from '../Characters';
import Create from '../Create';
import Spawn from '../Spawn';

import { STATE_CHARACTERS, STATE_CREATE, STATE_SPAWN } from '../../util/States';

library.add(fab, fas);

export default () => {
	const hidden = useSelector((state) => state.app.hidden);
	const appState = useSelector((state) => state.app.state);
	const loading = useSelector((state) => state.loader.loading);

	const muiTheme = createTheme({
		typography: {
			fontFamily: ['Source Sans Pro', 'sans-serif'].join(','),
		},
		palette: {
			primary: {
				main: '#8685EF',
				light: '#aaa8f3',
				dark: '#5441d1',
				contrastText: '#ffffff',
			},
			secondary: {
				main: '#424242',
				light: '#757575',
				dark: '#212121',
				contrastText: '#ffffff',
			},
			error: {
				main: '#6e1616',
				light: '#a13434',
				dark: '#430b0b',
			},
			success: {
				main: '#52984a',
				light: '#60eb50',
				dark: '#244a20',
			},
			warning: {
				main: '#f09348',
				light: '#f2b583',
				dark: '#b05d1a',
			},
			info: {
				main: '#247ba5',
				light: '#247ba5',
				dark: '#175878',
			},
			text: {
				main: '#212121',
				alt: '#424242',
				info: '#212121',
				light: '#e3f2fd',
				dark: '#212121',
			},
			border: {
				main: '#212121',
				light: '#ffffff',
				dark: '#26292d',
				input: 'rgba(255, 255, 255, 0.23)',
				divider: 'rgba(255, 255, 255, 0.12)',
			},
			mode: 'dark',
		},
		components: {
			MuiCssBaseline: {
				styleOverrides: {
					html: {
						background:
							process.env.NODE_ENV !== 'production'
								? '#1e1e1e'
								: 'transparent',
						'input::-webkit-outer-spin-button, input::-webkit-inner-spin-button':
							{
								WebkitAppearance: 'none',
								margin: 0,
							},
					},
					'*': {
						'&::-webkit-scrollbar': {
							width: 6,
						},
						'&::-webkit-scrollbar-thumb': {
							background: `#1565c0`,
							transition: 'background ease-in 0.15s',
						},
						'&::-webkit-scrollbar-thumb:hover': {
							background: `#2196f3`,
						},
						'&::-webkit-scrollbar-track': {
							background: 'transparent',
						},
					},
				},
			},
			MuiPaper: {
				styleOverrides: {
					root: {
						background: '#212121',
					},
				},
			},
		},
	});

	let display;

	switch (appState) {
		case STATE_CHARACTERS:
			display = <Characters />;
			break;
		case STATE_CREATE:
			display = <Create />;
			break;
		case STATE_SPAWN:
			display = <Spawn />;
			break;
		default:
			display = <Splash />;
			break;
	}

	return (
		<StyledEngineProvider injectFirst>
			<ThemeProvider theme={muiTheme}>
				<MantineProvider withGlobalStyles withNormalizeCSS>
					<CssBaseline />
					{!hidden && (
						<div className="App">
							{loading ? <Loader /> : display}
						</div>
					)}
				</MantineProvider>
			</ThemeProvider>
		</StyledEngineProvider>
	);
};
