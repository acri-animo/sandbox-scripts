import React, { Fragment, useEffect, useState } from 'react';
import Nui from "../../util/Nui"
import { useSelector } from "react-redux"
import { MenuItem, TextField, Typography, IconButton, Tooltip } from "@mui/material"
import { makeStyles } from "@mui/styles"
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { faMapLocationDot } from "@fortawesome/free-solid-svg-icons"

import Welcome from "./components/Welcome"
import Unauthorized from "./components/Unauthorized"
import FastestRacer from "./components/FastestRacer"

export const TrackTypes = {
  laps: "Laps",
  p2p: "Point to Point",
}

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "100%",
    background: "#16213e",
    overflowY: "auto",
  },
  user: {
    width: "100%",
    padding: "20px",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontSize: 24,
    fontWeight: "600",
    borderBottom: "2px solid rgba(134, 133, 239, 0.3)",
    background: "rgba(134, 133, 239, 0.1)",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    color: "white",
    "& span": {
      color: "#8685EF",
      fontWeight: "bold",
    },
  },
  content: {
    padding: 16,
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    height: "94%",
  },
  noTracks: {
    width: "100%",
    textAlign: "center",
    fontSize: 18,
    fontWeight: "500",
    marginTop: "25%",
    color: "rgba(255, 255, 255, 0.7)",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  selector: {
    height: "12%",
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
      marginTop: "4px",
    },
  },
  records: {
    marginTop: 16,
    height: "87%",
    overflow: "auto",
    "&::-webkit-scrollbar": {
      width: 6,
    },
    "&::-webkit-scrollbar-thumb": {
      background: "rgba(134, 133, 239, 0.4)",
      borderRadius: "3px",
    },
    "&::-webkit-scrollbar-thumb:hover": {
      background: "#8685EF",
    },
    "&::-webkit-scrollbar-track": {
      background: "transparent",
    },
  },
  mapButton: {
    width: "48px",
    height: "48px",
    borderRadius: "12px",
    backgroundColor: "rgba(134, 133, 239, 0.2)",
    border: "1px solid rgba(134, 133, 239, 0.3)",
    color: "#8685EF",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(134, 133, 239, 0.3)",
      transform: "scale(1.05)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(134, 133, 239, 0.5)",
    },
  },
  menuItem: {
    color: "white",
    fontSize: "14px",
    padding: "10px 16px",
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

export default () => {
  const classes = useStyles()
  const onDuty = useSelector((state) => state.data.data.onDuty)
  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline)
  const tracks = useSelector((state) => state.data.data.tracks)

  const [selected, setSelected] = useState("")
  const [history, setHistory] = useState([])

  useEffect(() => {
    setSelected(tracks[0]?.id ?? "")
  }, [tracks])

  useEffect(() => {
    const selectedTrack = tracks.find((t) => t.id === selected)
    setHistory(selectedTrack?.Fastest ?? [])
  }, [selected, tracks])

  const onChange = (e) => {
    setSelected(e.target.value)
  }

  const showTrackBlips = async () => {
    if (selected) {
      try {
        const response = await Nui.send("ShowTrackBlips", {
          trackId: selected,
        })
        if (response.status === "ok") {
          console.log("Track blips toggled successfully")
        } else {
          console.error("Error toggling blips:", response.message)
        }
      } catch (error) {
        console.error("NUI send failed:", error)
      }
    }
  }

  return (
    <div className={classes.wrapper}>
      {Boolean(alias) && onDuty !== "police" ? (
        <Fragment>
          <div className={classes.user}>
            TRACKS
            {selected && (
              <Tooltip title="Toggle Checkpoints">
                <IconButton className={classes.mapButton} onClick={showTrackBlips}>
                  <FontAwesomeIcon icon={faMapLocationDot} />
                </IconButton>
              </Tooltip>
            )}
          </div>
          {tracks.length > 0 ? (
            <div className={classes.content}>
              <div className={classes.selector}>
                <TextField
                  select
                  fullWidth
                  label="Track"
                  name="track"
                  variant="outlined"
                  value={selected}
                  onChange={onChange}
                >
                  {tracks.map((track) => (
                    <MenuItem key={track.id} value={track.id} className={classes.menuItem}>
                      {track.Name}
                    </MenuItem>
                  ))}
                </TextField>
              </div>
              <div className={classes.records}>
                {history.length > 0 ? (
                  history.map((lap, k) => <FastestRacer key={k} rank={k + 1} racer={lap} />)
                ) : (
                  <Typography className={classes.noTracks}>Track Has No Lap Records</Typography>
                )}
              </div>
            </div>
          ) : (
            <Typography className={classes.noTracks}>No Tracks Exist</Typography>
          )}
        </Fragment>
      ) : alias ? (
        <Unauthorized />
      ) : (
        <Welcome />
      )}
    </div>
  )
}