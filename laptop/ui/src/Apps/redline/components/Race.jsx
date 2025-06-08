import React from 'react';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const useStyles = makeStyles((theme) => ({
  race: {
    display: "flex",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    borderBottom: "1px solid rgba(134, 133, 239, 0.2)",
    borderRadius: "12px",
    marginTop: "12px",
    marginBottom: "8px",
    padding: "12px 16px",
    width: "90%",
    background: "rgba(134, 133, 239, 0.1)",
    transition: "all 0.2s ease",
    boxShadow: "0 2px 8px rgba(0, 0, 0, 0.1)",
    "&:hover": {
      background: "rgba(134, 133, 239, 0.2)",
      transform: "translateY(-2px)",
      boxShadow: "0 4px 12px rgba(134, 133, 239, 0.2)",
      cursor: "pointer",
    },
  },
  classIcon: {
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
  },
  label: {
    flexGrow: 1,
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
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
    marginTop: 4,
    color: "white",
  },
  trackName: {
    fontSize: 14,
    lineHeight: "18px",
    color: "rgba(255, 255, 255, 0.7)",
    "& small": {
      fontSize: 12,
      color: "rgba(255, 255, 255, 0.5)",
      marginLeft: "6px",
    },
  },
  arrow: {
    width: 50,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    color: "#8685EF",
    fontSize: "18px",
  },
}))

export default ({ track, race, onViewRace }) => {
  const classes = useStyles()

  const handleClick = () => {
    if (onViewRace && race?.id) {
      onViewRace(race.id)
    }
  }

  if (!race || !track) return null

  return (
    <div className={classes.race} onClick={handleClick}>
      <div className={classes.classIcon}>{race.class !== "All" ? <span>{race.class}</span> : <span>ALL</span>}</div>
      <div className={classes.label}>
        <div className={classes.raceName}>{race.name}</div>
        <div className={classes.trackName}>
          {track.Name} <small>({Object.keys(race.racers || {}).length} Racers)</small>
        </div>
      </div>
      <div className={classes.arrow}>
        <FontAwesomeIcon icon={["far", "chevron-right"]} />
      </div>
    </div>
  )
}
