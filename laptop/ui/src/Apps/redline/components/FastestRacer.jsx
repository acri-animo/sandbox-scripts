import React from 'react';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import moment from 'moment';

const useStyles = makeStyles((theme) => ({
  race: {
    display: "flex",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    borderRadius: "12px",
    padding: "12px 16px",
    margin: "8px 0",
    background: "rgba(134, 133, 239, 0.1)",
    transition: "all 0.2s ease",
    alignItems: "center",
    boxShadow: "0 2px 8px rgba(0, 0, 0, 0.1)",
    "&:hover": {
      background: "rgba(134, 133, 239, 0.2)",
      transform: "translateY(-2px)",
      boxShadow: "0 4px 12px rgba(134, 133, 239, 0.2)",
      cursor: "pointer",
    },
  },
  placing: {
    width: 50,
    height: 50,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    borderRadius: "8px",
    background: "rgba(134, 133, 239, 0.15)",
    marginRight: "12px",
    "& span": {
      fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
      color: "#8685EF",
      fontSize: 22,
      fontWeight: "bold",
    },
    "&.first": {
      background: "rgba(255, 215, 0, 0.2)",
      "& span": {
        color: "#FFD700",
      },
    },
    "&.second": {
      background: "rgba(192, 192, 192, 0.2)",
      "& span": {
        color: "#C0C0C0",
      },
    },
    "&.third": {
      background: "rgba(205, 127, 50, 0.2)",
      "& span": {
        color: "#CD7F32",
      },
    },
  },
  label: {
    flexGrow: 1,
    maxWidth: "calc(100% - 100px)",
    width: "100%",
  },
  raceName: {
    fontSize: 16,
    fontWeight: "600",
    overflow: "hidden",
    whiteSpace: "nowrap",
    textOverflow: "ellipsis",
    lineHeight: "24px",
    color: "white",
  },
  trackName: {
    fontSize: 14,
    lineHeight: "18px",
    color: "rgba(255, 255, 255, 0.7)",
    "& small": {
      fontSize: 12,
      marginLeft: "6px",
    },
  },
  arrow: {
    width: 40,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    color: "#8685EF",
    fontSize: "18px",
  },
}))

export default ({ rank, racer, onViewProfile }) => {
  const classes = useStyles()

  const handleClick = () => {
    if (onViewProfile && racer?.alias) {
      onViewProfile(racer.alias)
    }
  }

  if (!racer || !rank) return null

  const duration = moment.duration(racer.lap_end - racer.lap_start)
  const placingClass = rank === 1 ? "first" : rank === 2 ? "second" : rank === 3 ? "third" : ""

  return (
    <div className={classes.race} onClick={handleClick}>
      <div className={`${classes.placing} ${placingClass}`}>
        <span>#{rank}</span>
      </div>
      <div className={classes.label}>
        <div className={classes.raceName}>
          {racer.alias} - {racer.car || "Unknown"}
        </div>
        <div className={classes.trackName}>
          Laptime:{" "}
          {`${String(duration.hours()).padStart(2, "0")}:${String(duration.minutes()).padStart(2, "0")}:${String(
            duration.seconds(),
          ).padStart(2, "0")}:${String(duration.milliseconds()).padStart(3, "0")}`}
        </div>
      </div>
      <div className={classes.arrow}>
        <FontAwesomeIcon icon={["far", "chevron-right"]} />
      </div>
    </div>
  )
}
