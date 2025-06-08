import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import {
	TextField,
	FormControl,
	MenuItem,
	Autocomplete,
	Drawer,
	Button,
	Box,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import { LocalizationProvider, DatePicker } from '@mui/x-date-pickers';
import { getCodeList } from 'country-list';
import { AdapterMoment } from '@mui/x-date-pickers/AdapterMoment';
import moment from 'moment';

import Nui from '../../util/Nui';
import { STATE_CHARACTERS } from '../../util/States';
import { CreateCharacter } from '../../util/NuiEvents';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		width: 650,
		padding: 25,
	},
	title: {
		textAlign: 'center',
		borderBottom: `2px solid ${theme.palette.border.divider}`,
		fontSize: 26,
		paddingBottom: 15,
		marginBottom: 15,
	},
	form: {
		display: 'flex',
		flexDirection: 'column',
		padding: '1% 0',
	},
	formControl: {
		width: '100%',
		display: 'block',
		margin: '10px 0',
	},
	formControlFull: {
		width: '100%',
		display: 'block',
		margin: '10px 0',
	},
	formControl2: {
		width: '100%',
		display: 'block',
		margin: '10px 0',
	},
	input: {
		width: '100%',
	},
	actionData: {
		textAlign: 'center',
		marginTop: 20,
	},
}));

const genders = [
	{ value: 0, label: 'Male' },
	{ value: 1, label: 'Female' },
];

const countriesOrigin = getCodeList();
const date = new Date();
date.setFullYear(date.getFullYear() - 18);

export default () => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const [open, setOpen] = useState(true);

	const countries = Object.keys(countriesOrigin).map((k) => ({
		label: countriesOrigin[k],
		value: k,
	}));

	const [state, setState] = useState({
		first: '',
		last: '',
		dob: moment().subtract(18, 'years'),
		gender: 0,
		bio: '',
		origin: null,
		originInput: '',
	});

	const onChange = (evt) => {
		if (evt.target.name === 'first' || evt.target.name === 'last') {
			setState({
				...state,
				[evt.target.name]: evt.target.value.replace(/\s/g, ''),
			});
		} else {
			setState({
				...state,
				[evt.target.name]: evt.target.value,
			});
		}
	};

	const onSubmit = (evt) => {
		evt.preventDefault();
		const data = {
			first: state.first,
			last: state.last,
			gender: state.gender,
			dob: state.dob,
			lastPlayed: -1,
			origin: state.origin,
		};

		Nui.send(CreateCharacter, data);
		dispatch({
			type: 'LOADING_SHOW',
			payload: { message: 'Creating Character' },
		});
		setOpen(false);
	};

	const onCancel = () => {
		dispatch({
			type: 'SET_STATE',
			payload: { state: STATE_CHARACTERS },
		});
		setOpen(false);
	};

	return (
		<LocalizationProvider dateAdapter={AdapterMoment}>
			<Drawer
				anchor="right"
				open={open}
				onClose={() => {}}
				ModalProps={{
					disableEscapeKeyDown: true,
				}}
				PaperProps={{
					sx: {
						width: 650,
						backgroundColor: (theme) =>
							`${theme.palette.secondary.dark}80`,
					},
				}}
			>
				<Box className={classes.wrapper}>
					<div className={classes.title}>Create Character</div>
					<form
						autoComplete="off"
						id="createForm"
						className={classes.form}
						onSubmit={onSubmit}
					>
						<FormControl className={classes.formControl}>
							<TextField
								className={classes.input}
								required
								label="First Name"
								name="first"
								variant="outlined"
								value={state.first}
								onChange={onChange}
							/>
						</FormControl>
						<FormControl className={classes.formControl}>
							<TextField
								className={classes.input}
								required
								label="Last Name"
								name="last"
								variant="outlined"
								value={state.last}
								onChange={onChange}
							/>
						</FormControl>
						<FormControl className={classes.formControl}>
							<Autocomplete
								className={classes.input}
								value={state.origin}
								onChange={(e, v) => {
									onChange({
										target: {
											name: 'origin',
											value: v,
										},
									});
								}}
								inputValue={state.originInput}
								onInputChange={(e, v) => {
									onChange({
										target: {
											name: 'originInput',
											value: v,
										},
									});
								}}
								options={countries}
								getOptionLabel={(option) =>
									option ? option.label : ''
								}
								renderInput={(params) => (
									<TextField
										{...params}
										label="Country of Origin"
										variant="outlined"
									/>
								)}
							/>
						</FormControl>
						<FormControl className={classes.formControl}>
							<TextField
								className={classes.input}
								required
								select
								label="Gender"
								name="gender"
								value={state.gender}
								onChange={onChange}
								variant="outlined"
							>
								{genders.map((option) => (
									<MenuItem
										key={option.value}
										value={option.value}
									>
										{option.label}
									</MenuItem>
								))}
							</TextField>
						</FormControl>
						<FormControl className={classes.formControl}>
							<DatePicker
								className={classes.input}
								openTo="year"
								autoOk
								animateYearScrolling
								disableFuture
								required
								label="Date of Birth"
								views={['year', 'month', 'day']}
								value={state.dob}
								onChange={(newDate) =>
									onChange({
										target: { name: 'dob', value: newDate },
									})
								}
								renderInput={(params) => (
									<TextField fullWidth {...params} />
								)}
								slotProps={{
									textField: {
										helperText: 'MM/DD/YYYY',
									},
								}}
							/>
						</FormControl>
						<FormControl className={classes.formControl}>
							<TextField
								className={classes.input}
								required
								label="Character Biography"
								name="bio"
								multiline
								rows="4"
								value={state.bio}
								onChange={onChange}
								variant="outlined"
							/>
						</FormControl>
					</form>
					<div className={classes.actionData}>
						<Button
							variant="contained"
							color="secondary"
							onClick={onCancel}
							sx={{ mr: 2 }}
						>
							Cancel
						</Button>
						<Button
							variant="contained"
							color="primary"
							type="submit"
							form="createForm"
						>
							Create
						</Button>
					</div>
				</Box>
			</Drawer>
		</LocalizationProvider>
	);
};
