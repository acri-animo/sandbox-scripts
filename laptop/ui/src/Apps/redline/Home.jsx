import React, { Fragment } from 'react';
import { useSelector } from "react-redux"
import { makeStyles } from "@mui/styles"
import { Avatar, IconButton, Typography } from "@mui/material"

import Welcome from "./components/Welcome"
import Unauthorized from "./components/Unauthorized"
import Race from "./components/Race"

const useStyles = makeStyles((theme) => ({
  wrapper: {
    position: "relative",
    height: "100%",
    background: "#16213e",
    overflow: "auto",
  },
  body: {
    padding: 10,
    height: "100%",
  },
  content: {
    height: "92%",
    width: "100%",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    alignItems: "center",
    overflowY: "auto",
    overflowX: "hidden",
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
  header: {
    width: "100%",
    padding: "20px",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontSize: 20,
    textAlign: "center",
    color: "white",
    fontWeight: "600",
  },
  user: {
    width: "100%",
    padding: "20px",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontSize: 20,
    fontWeight: "500",
    borderBottom: "2px solid rgba(134, 133, 239, 0.3)",
    background: "rgba(134, 133, 239, 0.1)",
    color: "white",
    "& span": {
      color: "#8685EF",
      fontWeight: "bold",
    },
  },
  userProfile: {
    position: "absolute",
    top: 15,
    right: 20,
  },
  profileButton: {
    background: "rgba(134, 133, 239, 0.2)",
    border: "2px solid rgba(134, 133, 239, 0.3)",
    borderRadius: "8px",
    transition: "all 0.2s ease",
    padding: "2px",
    "&:hover": {
      background: "rgba(134, 133, 239, 0.3)",
      transform: "scale(1.05)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(134, 133, 239, 0.5)",
    },
  },
  noRaces: {
    width: "100%",
    textAlign: "center",
    fontSize: 18,
    fontWeight: "500",
    marginTop: "25%",
    color: "rgba(255, 255, 255, 0.7)",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  invCount: {
    position: "absolute",
    fontSize: 12,
    bottom: 0,
    right: 0,
    zIndex: 10,
    background: "#8685EF",
    color: "white",
    padding: "2px 6px",
    borderRadius: 20,
  },
}))

export default ({ onViewRace, onViewProfile }) => {
  const classes = useStyles()
  const onDuty = useSelector((state) => state.data.data.onDuty)
  const sid = useSelector((state) => state.data.data.player.SID)
  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline)

  const tracks = useSelector((state) => state.data.data.tracks)
  const rawRaces = useSelector((state) => state.race.races)

  const races = Object.keys(rawRaces)
    .reduce((result, key) => {
      if (rawRaces[key].state != -1 && rawRaces[key].state != 2) {
        result.push(rawRaces[key])
      }
      return result
    }, [])
    .sort((a, b) => b.time - a.time)

  return (
    <div className={classes.wrapper}>
      {Boolean(alias) && onDuty !== "police" ? (
        <Fragment>
          <div className={classes.user}>
            Welcome Back <span>{alias?.name}</span>
          </div>
          <div className={classes.userProfile}>
            <IconButton className={classes.profileButton} onClick={() => onViewProfile(alias?.name, sid)}>
              <Avatar
                src={alias?.picture || ""}
                alt={alias?.name || "Profile"}
                sx={{
                  width: 40,
                  height: 40,
                  borderRadius: "6px",
                }}
              />
            </IconButton>
          </div>
          <div className={classes.content}>
            <div className={classes.header}>Pending Races</div>
            {races.length > 0 ? (
              races.map((race, k) => {
                const track = tracks.find((t) => t.id === race.track)
                return <Race key={`pending-${k}`} track={track} race={race} onViewRace={onViewRace} />
              })
            ) : (
              <Typography className={classes.noRaces}>No pending races available.</Typography>
            )}
          </div>
        </Fragment>
      ) : alias ? (
        <Unauthorized />
      ) : (
        <Welcome />
      )}
    </div>
  )
}