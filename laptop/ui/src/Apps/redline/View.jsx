import React, { Fragment, useEffect, useState } from 'react';
import { useDispatch, useSelector } from "react-redux"
import { IconButton, List, ListItem, ListItemText, TextField, Typography, Tooltip } from "@mui/material"
import { makeStyles } from "@mui/styles"
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { faPlay, faSignOutAlt, faUserPlus, faFlagCheckered, faSignInAlt } from "@fortawesome/pro-solid-svg-icons"

import { useAlert } from "../../hooks"
import { Confirm, Loader, Modal } from "../../components"
import { CurrencyFormat } from "../../util/Parser"
import Racer from "./components/Racer"
import Nui from "../../util/Nui"
import { GhostTypes } from "."

const useStyles = makeStyles((theme) => ({
  content: {
    height: "87%",
    overflow: "hidden",
    background: "#16213e",
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
    fontSize: 24,
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontWeight: "600",
    color: "white",
    marginTop: 20,
    marginBottom: 20,
    textAlign: "center",
    position: "relative",
    "& span": {
      background: "rgba(134, 133, 239, 0.2)",
      borderRadius: "8px",
      padding: "8px 20px",
      border: "1px solid rgba(134, 133, 239, 0.3)",
      zIndex: 1,
      position: "relative",
    },
  },
  flexContainer: {
    display: "flex",
    padding: "0 16px",
    gap: "16px",
    height: "100%",
  },
  detailsContainer: {
    flex: "0 0 35%",
    padding: "20px",
    borderRadius: "12px",
    background: "rgba(134, 133, 239, 0.15)",
    border: "1px solid rgba(134, 133, 239, 0.2)",
    overflowY: "hidden",
    height: "40%",
    position: "relative",
  },
  racersContainer: {
    flex: "0 0 60%",
    padding: "20px",
    textAlign: "center",
    borderRadius: "12px",
    background: "rgba(134, 133, 239, 0.15)",
    border: "1px solid rgba(134, 133, 239, 0.2)",
    display: "flex",
    flexDirection: "column",
    height: "90%",
  },
  racersInner: {
    flex: 1,
    maxHeight: "100%",
    overflowY: "auto",
    padding: "0 16px",
    listStyle: "none !important",
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
  item: {
    display: "flex",
    alignItems: "center",
    marginBottom: 16,
    padding: "8px 0",
  },
  label: {
    fontSize: 14,
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    color: "rgba(255, 255, 255, 0.7)",
    display: "flex",
    alignItems: "center",
    gap: 8,
    marginRight: 12,
    minWidth: "80px",
    "& svg": {
      fontSize: 14,
      color: "#8685EF",
    },
  },
  value: {
    fontSize: 16,
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    color: "white",
    fontWeight: "500",
    transition: "color 0.2s ease",
    "&.clickable:hover": {
      cursor: "pointer",
      color: "#8685EF",
    },
  },
  closeButton: {
    position: "absolute",
    height: 48,
    width: 48,
    top: 60,
    right: 10,
    borderRadius: "12px",
    backgroundColor: "rgba(255, 107, 107, 0.2)",
    border: "1px solid rgba(255, 107, 107, 0.3)",
    color: "#ff6b6b",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(255, 107, 107, 0.3)",
      transform: "scale(1.05)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(255, 107, 107, 0.5)",
    },
  },
  buttonContainer: {
    marginTop: 16,
    display: "flex",
    flexDirection: "column",
    gap: 8,
  },
  actionButtons: {
    position: "absolute",
    top: 12,
    right: 12,
    display: "flex",
    gap: 8,
  },
  actionButton: {
    width: "40px",
    height: "40px",
    borderRadius: "8px",
    transition: "all 0.2s ease",
    "&:focus": {
      outline: "none",
      boxShadow: "none",
    },
    "&.start": {
      color: "#51cf66",
      backgroundColor: "rgba(81, 207, 102, 0.2)",
      border: "1px solid rgba(81, 207, 102, 0.3)",
      "&:hover": {
        backgroundColor: "rgba(81, 207, 102, 0.3)",
        transform: "scale(1.05)",
      },
    },
    "&.cancel": {
      color: "#ff6b6b",
      backgroundColor: "rgba(255, 107, 107, 0.2)",
      border: "1px solid rgba(255, 107, 107, 0.3)",
      "&:hover": {
        backgroundColor: "rgba(255, 107, 107, 0.3)",
        transform: "scale(1.05)",
      },
    },
    "&.invite": {
      color: "#8685EF",
      backgroundColor: "rgba(134, 133, 239, 0.2)",
      border: "1px solid rgba(134, 133, 239, 0.3)",
      "&:hover": {
        backgroundColor: "rgba(134, 133, 239, 0.3)",
        transform: "scale(1.05)",
      },
    },
    "&.join": {
      color: "#51cf66",
      backgroundColor: "rgba(81, 207, 102, 0.2)",
      border: "1px solid rgba(81, 207, 102, 0.3)",
      "&:hover": {
        backgroundColor: "rgba(81, 207, 102, 0.3)",
        transform: "scale(1.05)",
      },
    },
    "&.leave": {
      color: "#ffd43b",
      backgroundColor: "rgba(255, 212, 59, 0.2)",
      border: "1px solid rgba(255, 212, 59, 0.3)",
      "&:hover": {
        backgroundColor: "rgba(255, 212, 59, 0.3)",
        transform: "scale(1.05)",
      },
    },
  },
  sectionLabel: {
    color: "#8685EF",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontWeight: "600",
    fontSize: "16px",
    marginBottom: "12px",
    textAlign: "left",
  },
  noracers: {
    color: "rgba(255, 255, 255, 0.7)",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
    fontSize: "16px",
    marginTop: "20px",
  },
}))

export default ({ id, onClose, onViewProfile }) => {
  const classes = useStyles()
  const showAlert = useAlert()
  const dispatch = useDispatch()

  const onDuty = useSelector((state) => state.data.data.onDuty)
  const sid = useSelector((state) => state.data.data.player.SID)
  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline?.name)
  const inRace = useSelector((state) => state.race.inRace)
  const tracks = useSelector((state) => state.data.data.tracks)
  const raceData = useSelector((state) => state.race.races[id])

  const activePhaseType = GhostTypes.filter((g) => g.value === raceData?.phasing)[0]

  const [loaded, setLoaded] = useState(false)
  const [track, setTrack] = useState(null)
  const [removing, setRemoving] = useState(null)
  const [winnings, setWinnings] = useState(null)
  const [inviting, setInviting] = useState(false)

  useEffect(() => {
    setLoaded(false)
  }, [id])

  useEffect(() => {
    if (!raceData) return
    const trackData = tracks.filter((t) => t.id === raceData.track)[0]
    setTrack(trackData)
    setLoaded(true)
  }, [raceData, tracks])

  const onRacerClick = (racer) => {
    if (onViewProfile) onViewProfile(racer)
  }

  const onTrackClick = (trackId) => {
    showAlert("Track viewing not implemented in tab system")
  }

  const joinRace = async () => {
    try {
      const res = await (await Nui.send("JoinRace", raceData.id)).json()
      showAlert(res ? "Joined Race" : "Unable to Join Race")
      if (res) {
        dispatch({
          type: "I_RACE",
          payload: { state: true },
        })
      }
    } catch (err) {
      console.error(err)
      showAlert("Unable to Join Race")
    }
  }

  const leaveRace = async () => {
    try {
      const res = await (await Nui.send("LeaveRace", raceData.id)).json()
      showAlert(res ? "Left Race" : "Unable to Leave Race")
      if (res) {
        dispatch({
          type: "I_RACE",
          payload: { state: false },
        })
        if (onClose) onClose()
      }
    } catch (err) {
      console.error(err)
      showAlert("Unable to Leave Race")
    }
  }

  const cancelRace = async () => {
    if (raceData.state !== 0) {
      showAlert("Race cannot be canceled at this time")
      return
    }

    try {
      const res = await (await Nui.send("CancelRace", raceData.id)).json()
      if (res) {
        dispatch({
          type: "I_RACE",
          payload: { state: false },
        })
        showAlert("Race Cancelled")
        if (onClose) onClose()
      } else {
        showAlert("Unable to Cancel Race")
      }
    } catch (err) {
      console.error(err)
      showAlert("Error Cancelling Race")
    }
  }

  const startRace = async () => {
    try {
      const res = await (await Nui.send("StartRace", raceData.id)).json()
      showAlert(!res?.failed ? "Starting Race" : res.message)
    } catch (err) {
      console.error(err)
      showAlert("Unable to Start Race")
    }
  }

  const endRace = async () => {
    try {
      const res = await (await Nui.send("EndRace", raceData.id)).json()
      showAlert(res ? "Event Ended" : "Unable to End Event")
      if (res) {
        dispatch({
          type: "I_RACE",
          payload: { state: false },
        })
        if (onClose) onClose()
      }
    } catch (err) {
      console.error(err)
      showAlert("Error Ending Event")
    }
  }

  const onStartRemove = (alias) => {
    setRemoving(alias)
  }

  const onConfirmRemove = async () => {
    try {
      const res = await (
        await Nui.send("RemoveFromRace", {
          id: raceData.id,
          alias: removing,
        })
      ).json()
      showAlert(res ? `${removing} Removed From Event` : "Unable to Remove From Event")
    } catch (err) {
      console.error(err)
      showAlert("Error Removing From Event")
    }
    setRemoving(null)
  }

  const onInvite = async (e) => {
    e.preventDefault()
    try {
      const res = await (
        await Nui.send("SendInvite", {
          id: raceData.id,
          alias: e.target.alias.value,
        })
      ).json()
      showAlert(res ? `Event Invite Sent` : "Unable to Send Invite")
    } catch (err) {
      console.error(err)
      showAlert("Error Sending Invite")
    }
    setInviting(false)
  }

  return (
    <Fragment>
      {Boolean(alias) && onDuty !== "police" ? (
        <>
          {!loaded || !raceData || !track ? (
            <Loader static text="Loading Race Data" />
          ) : (
            <div className={classes.content}>
              <IconButton className={classes.closeButton} onClick={onClose}>
                <FontAwesomeIcon icon={["fas", "times"]} />
              </IconButton>
              <div className={classes.header}>
                <span>Event #{raceData.id} Details</span>
              </div>
              <div className={classes.flexContainer}>
                <div className={classes.detailsContainer}>
                  <div className={classes.actionButtons}>
                    {raceData?.host_id === sid && raceData.state === 0 && (
                      <>
                        <Tooltip title="Start Race">
                          <IconButton className={`${classes.actionButton} start`} onClick={startRace}>
                            <FontAwesomeIcon icon={faPlay} />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Cancel Race">
                          <IconButton className={`${classes.actionButton} cancel`} onClick={cancelRace}>
                            <FontAwesomeIcon icon={["fas", "times"]} />
                          </IconButton>
                        </Tooltip>
                        {raceData.access === "invite" && (
                          <Tooltip title="Invite Racer">
                            <IconButton className={`${classes.actionButton} invite`} onClick={() => setInviting(true)}>
                              <FontAwesomeIcon icon={faUserPlus} />
                            </IconButton>
                          </Tooltip>
                        )}
                      </>
                    )}
                    {raceData?.host_id === sid && raceData.state !== 0 && raceData.state !== 2 && (
                      <Tooltip title="End Race">
                        <IconButton className={`${classes.actionButton} cancel`} onClick={endRace}>
                          <FontAwesomeIcon icon={faFlagCheckered} />
                        </IconButton>
                      </Tooltip>
                    )}
                    {(raceData?.state === 0 || raceData?.state === 1) && raceData.racers[alias] && (
                      <Tooltip title="Leave Race">
                        <IconButton className={`${classes.actionButton} leave`} onClick={leaveRace}>
                          <FontAwesomeIcon icon={faSignOutAlt} />
                        </IconButton>
                      </Tooltip>
                    )}
                    {!inRace && raceData?.state === 0 && !raceData.racers[alias] && raceData.access === "public" && (
                      <Tooltip title="Join Race">
                        <IconButton className={`${classes.actionButton} join`} onClick={joinRace}>
                          <FontAwesomeIcon icon={faSignInAlt} />
                        </IconButton>
                      </Tooltip>
                    )}
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "user"]} />
                      Host:
                    </div>
                    <div className={`${classes.value} clickable`} onClick={() => onRacerClick(raceData.host)}>
                      {raceData.host}
                    </div>
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "flag"]} />
                      State:
                    </div>
                    <div className={classes.value}>
                      {raceData.state === -1
                        ? "Cancelled"
                        : raceData.state === 0
                          ? "Setting Up"
                          : raceData.state === 1
                            ? "In Progress"
                            : raceData.state === 2
                              ? "Finished"
                              : "Unknown"}
                    </div>
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "money-bill-alt"]} />
                      Buy In:
                    </div>
                    <div className={classes.value}>
                      {raceData.buyin > 0 ? CurrencyFormat.format(raceData.buyin) : "None"}
                    </div>
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "map"]} />
                      Track:
                    </div>
                    <div className={`${classes.value} clickable`} onClick={() => onTrackClick(raceData.id)}>
                      {track?.Name} ({track?.Distance})
                    </div>
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "redo"]} />
                      Laps:
                    </div>
                    <div className={classes.value}>{raceData.laps}</div>
                  </div>
                  <div className={classes.item}>
                    <div className={classes.label}>
                      <FontAwesomeIcon icon={["far", "ghost"]} />
                      Phasing:
                    </div>
                    <div className={classes.value}>{activePhaseType ? activePhaseType.label : "Disabled"}</div>
                  </div>
                </div>
                <div className={classes.racersContainer}>
                  <div className={classes.sectionLabel}>Racers</div>
                  <div className={classes.racersInner}>
                    {Object.keys(raceData.racers).length > 0 ? (
                      raceData.state === 2 ? (
                        <List style={{ listStyle: "none" }}>
                          {Object.keys(raceData.racers).filter((r) => raceData.racers[r].finished).length > 0 && (
                            <Fragment>
                              <ListItem>
                                <div className={classes.sectionLabel}>Podium</div>
                              </ListItem>
                              {Object.keys(raceData.racers)
                                .filter((r) => raceData.racers[r].finished)
                                .sort((a, b) => raceData.racers[a].place - raceData.racers[b].place)
                                .slice(0, 3)
                                .map((racer) => (
                                  <Racer
                                    key={racer}
                                    name={racer}
                                    sid={sid}
                                    race={raceData}
                                    track={track}
                                    racer={raceData.racers[racer]}
                                    onWinnings={setWinnings}
                                    onViewProfile={onViewProfile}
                                  />
                                ))}
                            </Fragment>
                          )}
                          {Object.keys(raceData.racers).filter(
                            (r) => raceData.racers[r].finished && raceData.racers[r].place > 3,
                          ).length > 0 && (
                            <Fragment>
                              <ListItem>
                                <div className={classes.sectionLabel}>Other Racers</div>
                              </ListItem>
                              {Object.keys(raceData.racers)
                                .filter((r) => raceData.racers[r].finished && raceData.racers[r].place > 3)
                                .sort((a, b) => raceData.racers[a].place - raceData.racers[b].place)
                                .map((racer) => (
                                  <Racer
                                    key={racer}
                                    name={racer}
                                    race={raceData}
                                    track={track}
                                    racer={raceData.racers[racer]}
                                    onWinnings={setWinnings}
                                    onViewProfile={onViewProfile}
                                  />
                                ))}
                            </Fragment>
                          )}
                          {Object.keys(raceData.racers).filter((r) => !raceData.racers[r].finished).length > 0 && (
                            <Fragment>
                              <ListItem>
                                <div className={classes.sectionLabel}>DNF'd</div>
                              </ListItem>
                              {Object.keys(raceData.racers)
                                .filter((r) => !raceData.racers[r].finished)
                                .map((racer) => (
                                  <Racer
                                    key={racer}
                                    name={racer}
                                    race={raceData}
                                    track={track}
                                    racer={raceData.racers[racer]}
                                    onWinnings={setWinnings}
                                    onViewProfile={onViewProfile}
                                  />
                                ))}
                            </Fragment>
                          )}
                        </List>
                      ) : (
                        Object.keys(raceData.racers).map((racer) => (
                          <Racer
                            key={racer}
                            name={racer}
                            race={raceData}
                            track={track}
                            racer={raceData.racers[racer]}
                            onRemove={onStartRemove}
                            onViewProfile={onViewProfile}
                          />
                        ))
                      )
                    ) : (
                      <div className={classes.noracers}>No Racers Signed Up</div>
                    )}
                  </div>
                </div>
              </div>
              {removing && (
                <Confirm
                  title={`Remove ${removing} From Event?`}
                  open={Boolean(removing)}
                  confirm="Yes"
                  decline="No"
                  onConfirm={onConfirmRemove}
                  onDecline={() => setRemoving(null)}
                />
              )}
              {winnings && (
                <Modal open={Boolean(winnings)} title={`${winnings.name} Winnings`} onClose={() => setWinnings(null)}>
                  <List className={classes.winningsBody}>
                    {winnings?.reward?.cash && (
                      <ListItem>
                        <ListItemText primary="Cash" secondary={`$${winnings.reward.cash}`} />
                      </ListItem>
                    )}
                    {winnings?.reward?.crypto && (
                      <ListItem>
                        <ListItemText
                          primary="Crypto"
                          secondary={`${winnings.reward.crypto} $${winnings.reward.coin}`}
                        />
                      </ListItem>
                    )}
                  </List>
                </Modal>
              )}
              {inviting && (
                <Modal
                  form
                  open={inviting}
                  title="Invite Racer To Event"
                  submitLang="Send Invite"
                  onAccept={onInvite}
                  onClose={() => setInviting(false)}
                >
                  <TextField
                    fullWidth
                    autoFocus
                    required
                    label="Alias"
                    name="alias"
                    color="secondary"
                    inputProps={{ maxLength: 32 }}
                    variant="outlined"
                    className={classes.creatorInput}
                  />
                </Modal>
              )}
            </div>
          )}
        </>
      ) : (
        <Typography className={classes.noRaces}>{alias ? "Unauthorized: On Duty" : "Please Set Up Profile"}</Typography>
      )}
    </Fragment>
  )
}
