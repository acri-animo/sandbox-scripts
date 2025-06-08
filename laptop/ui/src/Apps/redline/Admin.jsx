import React, { useState, Fragment } from 'react';
import { useDispatch, useSelector } from "react-redux"
import {
  Button,
  MenuItem,
  TextField,
  AccordionActions,
  Accordion,
  AccordionDetails,
  AccordionSummary,
  Typography,
  List,
  ListItem,
  ListItemText,
  Divider,
  IconButton,
} from "@mui/material"
import { makeStyles } from "@mui/styles"
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"

import { useAlert } from "../../hooks"
import Nui from "../../util/Nui"
import { Modal, Confirm } from "../../components"
import { TrackTypes } from "."

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "100%",
    background: "#16213e",
    overflowY: "auto",
    padding: 10,
  },
  heading: {
    fontSize: "16px",
    flexBasis: "33.33%",
    flexShrink: 0,
    color: "white",
    fontWeight: "600",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  secondaryHeading: {
    fontSize: "14px",
    color: "rgba(255, 255, 255, 0.7)",
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif',
  },
  details: {
    "& h3": {
      color: "#8685EF",
    },
  },
  detailsList: {
    padding: 10,
  },
  buttons: {
    width: "100%",
    display: "flex",
    margin: "auto",
    gap: 10,
  },
  button: {
    width: "-webkit-fill-available",
    padding: 20,
    color: "#ffd43b",
    borderRadius: "8px",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(255, 212, 59, 0.1)",
      transform: "translateY(-1px)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(255, 212, 59, 0.3)",
    },
  },
  buttonNegative: {
    width: "-webkit-fill-available",
    padding: 20,
    color: "#ff6b6b",
    borderRadius: "8px",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(255, 107, 107, 0.1)",
      transform: "translateY(-1px)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(255, 107, 107, 0.3)",
    },
  },
  buttonPositive: {
    width: "-webkit-fill-available",
    padding: 20,
    color: "#51cf66",
    borderRadius: "8px",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(81, 207, 102, 0.1)",
      transform: "translateY(-1px)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(81, 207, 102, 0.3)",
    },
  },
  creatorInput: {
    marginBottom: 16,
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
  track: {
    background: "rgba(134, 133, 239, 0.1)",
    border: "1px solid rgba(134, 133, 239, 0.2)",
    borderRadius: "12px",
    margin: "8px 0",
    transition: "all 0.2s ease",
    "&:hover": {
      background: "rgba(134, 133, 239, 0.15)",
      transform: "translateY(-1px)",
    },
    "&.Mui-expanded": {
      background: "rgba(134, 133, 239, 0.2)",
    },
  },
  actionBar: {
    padding: "16px 20px",
    borderBottom: "2px solid rgba(134, 133, 239, 0.3)",
    background: "rgba(134, 133, 239, 0.1)",
    display: "flex",
    gap: 12,
    borderRadius: "8px 8px 0 0",
    marginBottom: "16px",
  },
  actionButton: {
    width: "48px",
    height: "48px",
    borderRadius: "12px",
    color: "white",
    backgroundColor: "rgba(134, 133, 239, 0.2)",
    border: "1px solid rgba(134, 133, 239, 0.3)",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: "rgba(134, 133, 239, 0.3)",
      transform: "scale(1.05)",
    },
    "&:focus": {
      outline: "none",
      boxShadow: "0 0 0 2px rgba(134, 133, 239, 0.5)",
    },
    "&.active": {
      backgroundColor: "#8685EF",
      color: "white",
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
  const dispatch = useDispatch()
  const showAlert = useAlert()
  const tracks = useSelector((state) => state.data.data.tracks)
  const createState = useSelector((state) => state.race.creator)
  const onDuty = useSelector((state) => state.data.data.onDuty)
  const alias = useSelector((state) => state.data.data.player?.Profiles?.redline)

  const [expanded, setExpanded] = useState(null)
  const [saving, setSaving] = useState(false)
  const [deleting, setDeleting] = useState(null)
  const [resetting, setResetting] = useState(null)
  const [formData, setFormData] = useState({
    name: "",
    type: "laps",
  })

  const onCreate = async () => {
    try {
      const res = await (await Nui.send("CreateTrack")).json()
      showAlert(res ? "Creator Started" : "Unable to Start Creator")
      if (res) {
        dispatch({
          type: "RACE_STATE_CHANGE",
          payload: {
            state: {
              checkpoints: 0,
              distance: 0,
              type: "lap",
            },
          },
        })
      }
    } catch (err) {
      console.error(err)
      showAlert("Unable to Start Creator")
    }
  }

  const onCancel = async () => {
    try {
      await Nui.send("StopCreator")
    } catch (err) {
      console.error(err)
    }
    dispatch({
      type: "RACE_STATE_CHANGE",
      payload: { state: null },
    })
  }

  const onSave = async (e) => {
    e.preventDefault()
    const { name, type } = formData

    if (!name || !type) {
      showAlert("Please fill out all fields")
      return
    }

    try {
      const res = await (
        await Nui.send("FinishCreator", {
          name,
          type,
        })
      ).json()
      showAlert(res ? "Track Created" : "Unable to Create Track")
      setSaving(false)
      setFormData({ name: "", type: "laps" })
    } catch (err) {
      console.error(err)
      showAlert("Unable to Create Track")
      setSaving(false)
    }
  }

  const onDelete = async () => {
    try {
      const res = await (await Nui.send("DeleteTrack", deleting)).json()
      setDeleting(null)
      setExpanded(null)
      showAlert(res ? "Track Deleted" : "Unable to Delete Track")
    } catch (err) {
      console.error(err)
      setDeleting(null)
      setExpanded(null)
      showAlert("Unable to Delete Track")
    }
  }

  const onReset = async () => {
    try {
      const res = await (await Nui.send("ResetTrackHistory", resetting)).json()
      setResetting(null)
      showAlert(res ? "Track History Reset" : "Unable to Reset Track History")
    } catch (err) {
      console.error(err)
      setResetting(null)
      showAlert("Unable to Reset Track History")
    }
  }

  const handleInputChange = (e) => {
    const { name, value } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }))
  }

  return (
    <div className={classes.wrapper}>
      {Boolean(alias) && onDuty !== "police" ? (
        <Fragment>
          <div className={classes.actionBar}>
            {!createState ? (
              <IconButton className={classes.actionButton} onClick={onCreate} aria-label="Create Track">
                <FontAwesomeIcon icon={["far", "plus"]} />
              </IconButton>
            ) : (
              <>
                <IconButton className={classes.actionButton} onClick={onCancel} aria-label="Cancel">
                  <FontAwesomeIcon icon={["far", "xmark"]} />
                </IconButton>
                <IconButton
                  className={`${classes.actionButton} active`}
                  onClick={() => setSaving(true)}
                  aria-label="Save"
                >
                  <FontAwesomeIcon icon={["far", "floppy-disk"]} />
                </IconButton>
              </>
            )}
          </div>
          {tracks.map((track, k) => (
            <Accordion
              key={`track-${k}`}
              className={classes.track}
              expanded={expanded === k}
              onChange={() => setExpanded(expanded === k ? null : k)}
            >
              <AccordionSummary
                expandIcon={<FontAwesomeIcon icon={["fas", "chevron-down"]} style={{ color: "#8685EF" }} />}
              >
                <Typography className={classes.heading}>{track.Name}</Typography>
                <Typography className={classes.secondaryHeading}>{track.Distance}</Typography>
              </AccordionSummary>
              <AccordionDetails>
                <List>
                  <ListItem>
                    <ListItemText
                      primary="Name"
                      secondary={track.Name}
                      primaryTypographyProps={{ style: { color: "#8685EF", fontWeight: "600" } }}
                      secondaryTypographyProps={{ style: { color: "white" } }}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemText
                      primary="Type"
                      secondary={TrackTypes[track.Type]}
                      primaryTypographyProps={{ style: { color: "#8685EF", fontWeight: "600" } }}
                      secondaryTypographyProps={{ style: { color: "white" } }}
                    />
                  </ListItem>
                  <ListItem>
                    <ListItemText
                      primary="Distance"
                      secondary={track.Distance}
                      primaryTypographyProps={{ style: { color: "#8685EF", fontWeight: "600" } }}
                      secondaryTypographyProps={{ style: { color: "white" } }}
                    />
                  </ListItem>
                </List>
              </AccordionDetails>
              <Divider style={{ backgroundColor: "rgba(134, 133, 239, 0.3)" }} />
              <AccordionActions>
                <Button size="small" className={classes.button} onClick={() => setResetting(track.id)}>
                  Reset Lap History
                </Button>
                <Button size="small" className={classes.buttonNegative} onClick={() => setDeleting(track.id)}>
                  Delete Track
                </Button>
              </AccordionActions>
            </Accordion>
          ))}
          <Confirm
            title="Delete Track?"
            open={deleting != null}
            confirm="Yes"
            decline="No"
            onConfirm={onDelete}
            onDecline={() => setDeleting(null)}
          />
          <Confirm
            title="Reset Track History?"
            open={resetting != null}
            confirm="Yes"
            decline="No"
            onConfirm={onReset}
            onDecline={() => setResetting(null)}
          />
          <Modal
            form
            open={saving}
            title="Create New Track"
            onClose={() => setSaving(false)}
            onAccept={onSave}
            submitLang="Save Track"
            closeLang="Cancel"
          >
            <TextField
              className={classes.creatorInput}
              fullWidth
              required
              label="Name"
              name="name"
              variant="outlined"
              value={formData.name}
              onChange={handleInputChange}
            />
            <TextField
              select
              fullWidth
              required
              variant="outlined"
              label="Type"
              name="type"
              value={formData.type}
              onChange={handleInputChange}
              className={classes.creatorInput}
            >
              {Object.keys(TrackTypes).map((key) => (
                <MenuItem key={key} value={key} className={classes.menuItem}>
                  {TrackTypes[key]}
                </MenuItem>
              ))}
            </TextField>
          </Modal>
        </Fragment>
      ) : (
        <Typography className={classes.noRaces}>{alias ? "Unauthorized: On Duty" : "Please Set Up Profile"}</Typography>
      )}
    </div>
  )
}
