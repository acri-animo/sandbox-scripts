import React, { Fragment, useState } from 'react';
import { Button, TextField, Grid, Alert, MenuItem } from "@mui/material"
import { makeStyles } from "@mui/styles"
import { useDispatch, useSelector } from "react-redux"

import { useAlert } from "../../hooks"
import Welcome from "./components/Welcome"
import Unauthorized from "./components/Unauthorized"
import Nui from "../../util/Nui"
import { AccessTypes, GhostTypes } from "."

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "100%",
    background: "#16213e",
    overflowY: "auto",
    padding: 16,
  },
  form: {
    height: "100%",
  },
  formBody: {
    padding: 16,
  },
  submitButton: {
    marginTop: 16,
    background: "#8685EF",
    color: "white",
    fontWeight: "600",
    borderRadius: "8px",
    padding: "12px",
    transition: "all 0.2s ease",
    "&:hover": {
      background: "#7674e8",
      transform: "translateY(-1px)",
      boxShadow: "0 4px 12px rgba(134, 133, 239, 0.3)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(134, 133, 239, 0.5)",
    },
  },
  creatorInput: {
    marginBottom: 5,
  },
  newInput: {
    "& .MuiOutlinedInput-root": {
      borderRadius: "8px",
      backgroundColor: "rgba(255, 255, 255, 0.05)",
      "& fieldset": {
        borderColor: "rgba(134, 133, 239, 0.3)",
        transition: "border-color 0.2s ease",
      },
      "&:hover fieldset": {
        borderColor: "rgba(134, 133, 239, 0.5)",
      },
      "&.Mui-focused fieldset": {
        borderColor: "#8685EF",
        boxShadow: "0 0 0 1px rgba(134, 133, 239, 0.2)",
      },
      "&.Mui-focused": {
        backgroundColor: "rgba(255, 255, 255, 0.08)",
      },
    },
    "& .MuiInputLabel-root": {
      color: "rgba(255, 255, 255, 0.7)",
      "&.Mui-focused": {
        color: "#8685EF",
      },
    },
    "& .MuiInputBase-input": {
      color: "white",
    },
    "& .MuiSelect-icon": {
      color: "rgba(255, 255, 255, 0.7)",
    },
    "& .MuiMenu-paper": {
      backgroundColor: "#1a1a2e",
      border: "1px solid rgba(134, 133, 239, 0.3)",
      borderRadius: "8px",
    },
    "& .MuiMenuItem-root": {
      color: "white",
      fontSize: "14px",
      transition: "all 0.2s ease",
      "&:hover": {
        backgroundColor: "rgba(134, 133, 239, 0.2)",
      },
      "&.Mui-selected": {
        backgroundColor: "rgba(134, 133, 239, 0.3)",
        color: "#8685EF",
        fontWeight: "500",
        "&:hover": {
          backgroundColor: "rgba(134, 133, 239, 0.4)",
        },
      },
    },
  },
  menuItem: {
    color: "white",
    fontSize: "14px",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(134, 133, 239, 0.2)",
    },
    "&.Mui-selected": {
      backgroundColor: "rgba(134, 133, 239, 0.3)",
      color: "#8685EF",
      fontWeight: "500",
      "&:hover": {
        backgroundColor: "rgba(134, 133, 239, 0.4)",
      },
    },
  },
}))

export default ({ onViewRace }) => {
  const classes = useStyles()
  const showAlert = useAlert()
  const dispatch = useDispatch()

  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline)

  const inRace = useSelector((state) => state.race.inRace)
  const tracks = useSelector((state) => state.data.data.tracks)
  const onDuty = useSelector((state) => state.data.data.onDuty)

  const [createState, setCreateState] = useState({
    name: "",
    host: alias?.name,
    buyin: "0",
    laps: 1,
    dnf_start: "3",
    dnf_time: "120",
    countdown: "8",
    phasing: false,
    class: "All",
    track: tracks.length > 0 ? tracks[0].id : null,
    access: "public",
    phasing: "none",
    phasingAdv: 0,
  })

  const onCreateChange = (e) => {
    setCreateState({
      ...createState,
      [e.target.name]: e.target.value,
    })
  }

  const onSubmit = async (e) => {
    e.preventDefault()
    if (inRace) {
      showAlert("Cannot create race while in another race")
      return
    }

    try {
      const res = await (await Nui.send("CreateRace", createState)).json()
      if (!res?.failed) {
        showAlert("Race Created")
        dispatch({
          type: "I_RACE",
          payload: { state: true },
        })
        if (onViewRace && res.id) {
          onViewRace(res.id)
        }
      } else {
        showAlert(res.message || "Unable To Create Race")
      }
    } catch (err) {
      console.error(err)
      showAlert("Unable To Create Race")
    }
  }

  return (
    <div className={classes.wrapper}>
      {Boolean(alias) && onDuty !== "police" ? (
        <form className={classes.form} onSubmit={onSubmit}>
          <Grid className={classes.formBody} container spacing={2}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                autoFocus
                required
                label="Event Name"
                name="name"
                variant="outlined"
                value={createState.name}
                onChange={onCreateChange}
                inputProps={{ maxLength: 32 }}
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                select
                required
                fullWidth
                label="Access"
                name="access"
                variant="outlined"
                value={createState.access}
                onChange={onCreateChange}
                className={classes.newInput}
              >
                {AccessTypes.map((access) => (
                  <MenuItem
                    key={access.value}
                    value={access.value}
                    disabled={access.disabled}
                    className={classes.menuItem}
                  >
                    {access.label}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Host"
                name="host"
                variant="outlined"
                disabled
                value={alias?.name}
                required
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                select
                required
                fullWidth
                label="Track"
                name="track"
                variant="outlined"
                value={createState.track}
                onChange={onCreateChange}
                className={classes.newInput}
              >
                {tracks.map((track) => (
                  <MenuItem key={track.id} value={track.id} className={classes.menuItem}>
                    {track.id} - {track.Name}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="# of Laps"
                name="laps"
                variant="outlined"
                type="number"
                disabled={tracks.find((t) => t.id === createState.track)?.Type === "p2p"}
                value={createState.laps}
                onChange={onCreateChange}
                required
                inputProps={{ min: 1 }}
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={4}>
              <TextField
                required
                fullWidth
                label="Countdown"
                name="countdown"
                variant="outlined"
                type="number"
                value={createState.countdown}
                onChange={onCreateChange}
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={8}>
              <TextField
                required
                fullWidth
                label="Buy In"
                name="buyin"
                variant="outlined"
                value={createState.buyin}
                onChange={onCreateChange}
                inputProps={{ type: "number", min: 0 }}
                className={classes.newInput}
              />
            </Grid>
            {createState.buyin > 0 && (
              <Grid item xs={12}>
                <Alert variant="filled" severity="warning">
                  Cash is not automatically gathered, as the race host you must manage getting the buy ins from all
                  racers and handle paying out winners
                </Alert>
              </Grid>
            )}
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="DNF Start"
                name="dnf_start"
                variant="outlined"
                type="number"
                value={createState.dnf_start}
                onChange={onCreateChange}
                required
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="DNF Time"
                name="dnf_time"
                variant="outlined"
                type="number"
                value={createState.dnf_time}
                onChange={onCreateChange}
                required
                className={classes.newInput}
              />
            </Grid>
            <Grid item xs={createState.phasing === "none" ? 12 : 7}>
              <TextField
                select
                required
                fullWidth
                label="Phasing"
                name="phasing"
                variant="outlined"
                value={createState.phasing}
                onChange={onCreateChange}
                className={classes.newInput}
              >
                {GhostTypes.map((access) => (
                  <MenuItem key={access.value} value={access.value} className={classes.menuItem}>
                    {access.label}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            {createState.phasing !== "none" && (
              <Grid item xs={5}>
                {createState.phasing === "timed" ? (
                  <TextField
                    fullWidth
                    label="Time (in Seconds)"
                    name="phasingAdv"
                    variant="outlined"
                    type="number"
                    value={createState.phasingAdv}
                    onChange={onCreateChange}
                    required
                    inputProps={{ min: 3, max: 60 }}
                    className={classes.newInput}
                  />
                ) : createState.phasing === "checkpoints" ? (
                  <TextField
                    fullWidth
                    label="# of Checkpoints"
                    name="phasingAdv"
                    variant="outlined"
                    type="number"
                    value={createState.phasingAdv}
                    onChange={onCreateChange}
                    required
                    inputProps={{ min: 1, max: 10 }}
                    className={classes.newInput}
                  />
                ) : null}
              </Grid>
            )}
            <Grid item xs={12}>
              <TextField
                select
                fullWidth
                label="Vehicle Class"
                name="class"
                variant="outlined"
                value={createState.class}
                onChange={onCreateChange}
                required
                className={classes.newInput}
              >
                <MenuItem value="D" className={classes.menuItem}>
                  D Class
                </MenuItem>
                <MenuItem value="C" className={classes.menuItem}>
                  C Class
                </MenuItem>
                <MenuItem value="B" className={classes.menuItem}>
                  B Class
                </MenuItem>
                <MenuItem value="A" className={classes.menuItem}>
                  A Class
                </MenuItem>
                <MenuItem value="S" className={classes.menuItem}>
                  S Class
                </MenuItem>
                <MenuItem value="All" className={classes.menuItem}>
                  All Classes
                </MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <Button type="submit" fullWidth className={classes.submitButton} variant="contained">
                Create Race
              </Button>
            </Grid>
          </Grid>
        </form>
      ) : alias ? (
        <Unauthorized />
      ) : (
        <Welcome />
      )}
    </div>
  )
}
