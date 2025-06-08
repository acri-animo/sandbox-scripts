import React, { Fragment } from 'react';
import { useSelector } from "react-redux"
import { Typography } from "@mui/material"
import { makeStyles } from "@mui/styles"

import Welcome from "./components/Welcome"
import Unauthorized from "./components/Unauthorized"
import Race from "./components/Race"

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
  content: {
    height: "87%",
    display: "flex",
    flexDirection: "column",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
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
  user: {
    width: "100%",
    padding: "20px",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontSize: 24,
    fontWeight: "600",
    borderBottom: "2px solid rgba(134, 133, 239, 0.3)",
    background: "rgba(134, 133, 239, 0.1)",
    color: "white",
    "& span": {
      color: "#8685EF",
      fontWeight: "bold",
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
}))

export default ({ onViewRace }) => {
  const classes = useStyles()
  const onDuty = useSelector((state) => state.data.data.onDuty)
  const sid = useSelector((state) => state.data.data.player.SID)
  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline)
  const tracks = useSelector((state) => state.data.data.tracks)
  const rawRaces = useSelector((state) => state.race.races)

  const races = Object.keys(rawRaces)
    .reduce((result, key) => {
      const track = tracks.find((t) => t.id === rawRaces[key].track)
      if (track && (rawRaces[key].state === -1 || rawRaces[key].state === 2)) {
        result.push(rawRaces[key])
      }
      return result
    }, [])
    .sort((a, b) => b.time - a.time)

  return (
    <div className={classes.wrapper}>
      {Boolean(alias) && onDuty !== "police" ? (
        <Fragment>
          <div className={classes.user}>HISTORY</div>
          <div className={classes.content}>
            {races.length > 0 ? (
              races.map((race, k) => {
                const track = tracks.find((t) => t.id === race.track)
                return <Race key={`recent-${k}`} track={track} race={race} onViewRace={onViewRace} />
              })
            ) : (
              <Typography className={classes.noRaces}>No Recent Races</Typography>
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