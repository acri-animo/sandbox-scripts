import React from 'react';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
	IconButton,
	ListItem,
	ListItemAvatar,
	ListItemSecondaryAction,
	ListItemText,
	Avatar,
} from '@mui/material';
import { useSelector } from 'react-redux';
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
    },
  },
  placing: {
    width: 40,
    height: 40,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    borderRadius: "8px",
    background: "rgba(134, 133, 239, 0.15)",
    marginRight: "12px",
    "& span": {
      fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
      color: "#8685EF",
      fontSize: 18,
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
    maxWidth: "calc(100% - 150px)",
    width: "100%",
    "& .MuiListItemText-primary": {
      color: "white",
      fontWeight: "500",
      fontSize: "16px",
    },
    "& .MuiListItemText-secondary": {
      color: "rgba(255, 255, 255, 0.7)",
      fontSize: "14px",
    },
  },
  avatar: {
    width: 40,
    height: 40,
    cursor: "pointer",
    borderRadius: "8px",
    border: "2px solid rgba(134, 133, 239, 0.3)",
    transition: "all 0.2s ease",
    "&:hover": {
      borderColor: "#8685EF",
      transform: "scale(1.05)",
    },
  },
  action: {
    fontSize: 18,
    color: "white",
    backgroundColor: "rgba(134, 133, 239, 0.2)",
    border: "1px solid rgba(134, 133, 239, 0.3)",
    transition: "all 0.2s ease",
    width: "36px",
    height: "36px",
    "&:hover": {
      backgroundColor: "rgba(134, 133, 239, 0.3)",
      transform: "scale(1.05)",
    },
    "&:not(:last-of-type)": {
      marginRight: 8,
    },
    "&.remove": {
      backgroundColor: "rgba(255, 107, 107, 0.2)",
      border: "1px solid rgba(255, 107, 107, 0.3)",
      color: "#ff6b6b",
      "&:hover": {
        backgroundColor: "rgba(255, 107, 107, 0.3)",
      },
    },
    "&.reward": {
      backgroundColor: "rgba(255, 212, 59, 0.2)",
      border: "1px solid rgba(255, 212, 59, 0.3)",
      color: "#ffd43b",
      "&:hover": {
        backgroundColor: "rgba(255, 212, 59, 0.3)",
      },
    },
  },
}))

export default ({ race, name, racer, onRemove = null, onWinnings = null, onViewProfile }) => {
  const classes = useStyles()
  const player = useSelector((state) => state.data.data.player)

  const playerAvatarImage = racer.picture || ""

  const handleViewProfile = () => {
    onViewProfile(name, racer.sid)
  }

  if (!racer || !name || !race || !player) return null
  const placingClass = racer.place === 1 ? "first" : racer.place === 2 ? "second" : racer.place === 3 ? "third" : ""

  if (racer.finished) {
    const duration = moment.duration(racer.fastest?.lap_end - racer.fastest?.lap_start)

    return (
      <ListItem className={classes.race}>
        <div className={`${classes.placing} ${placingClass}`}>
          <span>{racer.place ? `#${racer.place}` : "DNF"}</span>
        </div>
        <ListItemAvatar>
          <Avatar
            src={playerAvatarImage}
            className={classes.avatar}
            onClick={handleViewProfile}
            aria-label="View profile"
            variant="square"
          />
        </ListItemAvatar>
        <ListItemText
          className={classes.label}
          primary={name}
          secondary={
            racer.fastest ? (
              <span>
                Fastest Lap:{" "}
                {`${String(duration.hours()).padStart(2, "0")}:${String(duration.minutes()).padStart(
                  2,
                  "0",
                )}:${String(duration.seconds()).padStart(2, "0")}:${String(duration.milliseconds()).padStart(3, "0")}`}
              </span>
            ) : (
              "No lap time"
            )
          }
        />
        <ListItemSecondaryAction>
          {racer.reward && onWinnings && (
            <IconButton
              className={`${classes.action} reward`}
              onClick={() =>
                onWinnings({
                  name,
                  event: race.name,
                  reward: racer.reward,
                })
              }
              aria-label="View winnings"
            >
              <FontAwesomeIcon icon={["fas", "dollar"]} />
            </IconButton>
          )}
        </ListItemSecondaryAction>
      </ListItem>
    )
  } else {
    return (
      <ListItem className={classes.race}>
        <div className={classes.placing}>
          <span>-</span>
        </div>
        <ListItemAvatar>
          <Avatar
            src={playerAvatarImage}
            className={classes.avatar}
            onClick={handleViewProfile}
            aria-label="View profile"
            variant="square"
          />
        </ListItemAvatar>
        <ListItemText className={classes.label} primary={name} />
        <ListItemSecondaryAction>
          {onRemove && race.host_id === player.SID && racer.sid !== player.SID && (
            <IconButton className={`${classes.action} remove`} onClick={() => onRemove(name)} aria-label="Remove racer">
              <FontAwesomeIcon icon={["fas", "x"]} />
            </IconButton>
          )}
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
}
